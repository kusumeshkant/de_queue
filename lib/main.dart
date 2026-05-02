import 'package:dq_app/core/enums/db_tables_enums.dart';
import 'package:dq_app/core/manager/hive_manager.dart';
import 'package:dq_app/src/constants/app_config.dart';
import 'package:dq_app/src/constants/app_roles.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/l10n/app_translations.dart';
import 'package:dq_app/src/l10n/language_controller.dart';
import 'package:dq_app/src/presentation/order/order_confirmation_page.dart';
import 'package:dq_app/src/service_core/networks/graphql_service.dart';
import 'package:dq_app/src/service_core/networks/network_service.dart';
import 'package:dq_app/src/service_core/notifications/notification_service.dart';
import 'package:dq_app/src/presentation/auth/login/login_page.dart';
import 'package:dq_app/src/presentation/dashBoard/bottom_navigation.dart';
import 'package:dq_app/src/service_core/networks/graphql_client_provider.dart';
import 'package:dq_app/src/theme/app_theme.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await HiveManager.init();

  // Initialize push notifications
  await NotificationService.init();

  // Register controllers globally before app starts
  final themeController = Get.put(ThemeController(), permanent: true);
  Get.put(LanguageController(), permanent: true);
  Get.put(NetworkService(), permanent: true);

  // Load saved locale before building UI
  final savedLocale = await AppLocales.loadSaved();

  final cachedAuth = HiveManager.get(DbTable.auth, 'current');
  await GraphQLClientProvider.init(baseUrl: AppConfig.graphqlEndpoint);

  // Check for an in-progress order confirmation (app killed mid-confirmation)
  final pendingOrder = cachedAuth?['isLoggedIn'] == true
      ? await LocalStorage.loadPendingOrder()
      : null;

  // Cold-start role validation.
  // If Firebase says the user is logged in, verify they still have customer-
  // only access via the backend before showing the home screen.
  // Fail CLOSED: on network failure or FORBIDDEN, sign out and show login.
  final bool coldStartValid = await _validateColdStart();

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
/// Signs out Firebase and clears Hive cache if validation fails.
Future<bool> _validateColdStart() async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser == null) return false; // not logged in — show login

  final query =
      'query ValidateCustomerAccess { validateAppAccess(appId: "${AppId.customer}") { id } }';
  try {
    final result = await GraphQLService.performQuery(query: query);
    if (result.hasException) {
      // FORBIDDEN or other backend rejection — sign out and return false
      await firebaseUser.reload().catchError((_) {});
      await FirebaseAuth.instance.signOut();
      await HiveManager.delete(DbTable.auth, 'current');
      return false;
    }
    return true;
  } catch (_) {
    // Network failure on cold start — fail CLOSED.
    await FirebaseAuth.instance.signOut();
    await HiveManager.delete(DbTable.auth, 'current');
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
