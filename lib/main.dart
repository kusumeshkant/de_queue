import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:dq_app/core/observability/observability.dart';
import 'package:dq_app/core/enums/db_tables_enums.dart';
import 'package:dq_app/core/manager/hive_manager.dart';
import 'package:dq_app/src/constants/app_config.dart';
import 'package:dq_app/src/constants/app_roles.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/l10n/app_translations.dart';
import 'package:dq_app/src/l10n/language_controller.dart';
import 'package:dq_app/src/presentation/order/order_confirmation_page.dart';
import 'package:dq_app/src/service_core/networks/network_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dq_app/src/service_core/notifications/notification_service.dart';
import 'package:dq_app/src/presentation/auth/login/login_page.dart';
import 'package:dq_app/src/presentation/dashBoard/bottom_navigation.dart';
import 'package:dq_app/src/service_core/networks/graphql_client_provider.dart';
import 'package:dq_app/src/theme/app_theme.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() {
  runZonedGuarded(_bootstrap, (error, stack) {
    if (Get.isRegistered<CrashlyticsService>()) {
      Get.find<CrashlyticsService>().recordError(
        error, stack, category: CrashCategory.unknown, fatal: true,
      );
    }
    debugPrint('\n=== [DQ-App] UNCAUGHT ZONE ERROR ===\n$error\n$stack\n=====================================\n');
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    AppLogger.logFirebaseInit(success: true);
    final opts = Firebase.app().options;
    // ignore: avoid_print
    print('[DQ] flavor=${AppConfig.flavor}');
    // ignore: avoid_print
    print('[DQ] firebase.projectId=${opts.projectId}');
    // ignore: avoid_print
    print('[DQ] firebase.authDomain=${opts.authDomain}');
    // ignore: avoid_print
    print('[DQ] firebase.appId=${opts.appId}');
    if (kIsWeb) {
      // ignore: avoid_print
      print('[DQ] window.origin=${Uri.base.origin}');
    }
  } catch (e) {
    AppLogger.logFirebaseInit(success: false, error: e.toString());
    rethrow;
  }

  // Observability services — initialize immediately after Firebase.
  final crashlytics = Get.put(CrashlyticsService(), permanent: true);
  Get.put(AnalyticsService(), permanent: true);
  Get.put(PerformanceService(), permanent: true);
  Get.put(BreadcrumbService(), permanent: true);
  Get.put(ReleaseHealthService(), permanent: true);
  Get.put(FramePerformanceTracker(), permanent: true);
  Get.put(AnrDetector(), permanent: true);

  // Wire global error handlers to Crashlytics.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    crashlytics.recordFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack,
        category: CrashCategory.rendering, fatal: true);
    return true;
  };

  // Capture Google Sign-In redirect result (web only).
  // Must run before GraphQLClientProvider.init() so the auth state
  // (currentUser) is established when the GraphQL client is created.
  if (kIsWeb) {
    try {
      final redirectResult = await FirebaseAuth.instance.getRedirectResult();
      if (redirectResult.user != null) {
        // ignore: avoid_print
        print('[DQ] redirect-auth completed: uid=${redirectResult.user!.uid}');
      } else {
        // ignore: avoid_print
        print('[DQ] redirect-auth: no pending redirect');
      }
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('[DQ] redirect-auth error: ${e.code} — ${e.message}');
    } catch (e) {
      // ignore: avoid_print
      print('[DQ] redirect-auth: $e');
    }
  }

  await HiveManager.init();

  // Initialize push notifications
  await NotificationService.init();

  // Register controllers globally before app starts
  final themeController = Get.put(ThemeController(), permanent: true);
  Get.put(LanguageController(), permanent: true);
  Get.put(NetworkService(), permanent: true);

  // Load saved locale before building UI
  final savedLocale = await AppLocales.loadSaved();

  await GraphQLClientProvider.init(baseUrl: AppConfig.graphqlEndpoint);

  // Check for an in-progress order confirmation (app killed mid-confirmation).
  // Use Firebase state instead of the Hive cache to decide — it is the source
  // of truth and is already in memory at this point.
  final pendingOrder = FirebaseAuth.instance.currentUser != null
      ? await LocalStorage.loadPendingOrder()
      : null;

  // Cold-start role validation.
  // If Firebase says the user is logged in, verify they still have customer-
  // only access via the backend before showing the home screen.
  AppLogger.logValidateAccess('started', hint: 'cold-start');
  final bool coldStartValid = await _validateColdStart();
  AppLogger.logValidateAccess(coldStartValid ? 'granted' : 'denied', hint: 'cold-start');

  runApp(
    MyApp(
      initialThemeController: themeController,
      initialLocale: savedLocale,
      pendingOrder: pendingOrder,
      coldStartValid: coldStartValid,
    ),
  );
}

/// Returns true if the cold-start session is valid for the customer app.
///
/// Distinguishes two failure modes:
///   FORBIDDEN (wrong account type / role) → sign out Firebase, clear cache.
///   Network failure / timeout             → preserve Firebase session so the
///       user can tap "Sign In" and retry without re-entering credentials.
Future<bool> _validateColdStart() async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser == null) return false;

  const query = '''
    query ValidateCustomerAccess {
      validateAppAccess(appId: "${AppId.customer}") { id }
    }
  ''';

  try {
    // Use login client (no ErrorLink) so that UNAUTHENTICATED from the backend
    // does not trigger SessionManager.expireSession() and a false "Session
    // Expired" snackbar before _validateColdStart can evaluate the error type.
    // Only FORBIDDEN should cause a sign-out here — all other failures preserve
    // the Firebase session so the user can retry once the network is available.
    final result = await GraphQLClientProvider.buildLoginClient().query(
      QueryOptions(document: gql(query), fetchPolicy: FetchPolicy.networkOnly),
    );

    if (result.hasException) {
      final isForbidden = result.exception?.graphqlErrors
              .any((e) => e.extensions?['code'] == 'FORBIDDEN') ??
          false;

      if (isForbidden) {
        // Account does not have customer access — sign out definitively.
        await FirebaseAuth.instance.signOut();
        await HiveManager.delete(DbTable.auth, 'current');
      }
      // Non-FORBIDDEN (server error) — show login without signing out so
      // Firebase session is preserved for the next attempt.
      return false;
    }
    return true;
  } catch (_) {
    // Network / timeout — do NOT sign out. Firebase session is valid.
    // User will see LoginPage and can tap Sign In to retry once online.
    return false;
  }
}

class MyApp extends StatelessWidget {
  final ThemeController initialThemeController;
  final Locale initialLocale;
  final OrderEntity? pendingOrder;
  final bool coldStartValid;

  const MyApp({
    super.key,
    required this.initialThemeController,
    required this.initialLocale,
    this.pendingOrder,
    this.coldStartValid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DQ',
        translations: AppTranslations(),
        locale: Get.find<LanguageController>().currentLocale.value,
        fallbackLocale: AppLocales.english,
        theme: initialThemeController.isGreenTheme.value
            ? AppTheme.green
            : AppTheme.light,
        navigatorObservers: [AnalyticsNavigatorObserver()],
        home: _getInitialPage(),
      ),
    );
  }

  Widget _getInitialPage() {
    // coldStartValid is true only if Firebase session exists AND backend
    // confirmed the user has customer-only access (validateAppAccess passed).
    if (coldStartValid) {
      if (pendingOrder != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.to(
            () => OrderConfirmationPage(order: pendingOrder!),
            transition: Transition.fadeIn,
          );
        });
      }
      return const Bottomnavigation();
    }
    return LoginPage();
  }
}
