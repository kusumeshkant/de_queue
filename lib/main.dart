import 'package:dq_app/core/enums/db_tables_enums.dart';
import 'package:dq_app/core/manager/hive_manager.dart';
import 'package:dq_app/src/constants/app_config.dart';
import 'package:dq_app/src/l10n/app_translations.dart';
import 'package:dq_app/src/l10n/language_controller.dart';
import 'package:dq_app/src/service_core/networks/network_service.dart';
import 'package:dq_app/src/service_core/notifications/notification_service.dart';
import 'package:dq_app/src/presentation/auth/login/login_page.dart';
import 'package:dq_app/src/presentation/dashBoard/bottom_navigation.dart';
import 'package:dq_app/src/service_core/networks/graphql_client_provider.dart';
import 'package:dq_app/src/theme/app_theme.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await HiveManager.init();

  // Initialize push notifications
  await NotificationService.init();

  // Register controllers globally before app starts
  final themeController = Get.put(ThemeController(), permanent: true);
  Get.put(LanguageController(), permanent: true);
  Get.put(NetworkService(), permanent: true);

  // Load saved locale before building UI
  final savedLocale = await AppLocales.loadSaved();

  // Restore cached GraphQL token
  final cachedAuth = HiveManager.get(DbTable.auth, 'current');
  final cachedToken = cachedAuth?['token'] as String?;
  await GraphQLClientProvider.init(
    baseUrl: AppConfig.graphqlEndpoint,
    token: cachedToken,
  );

  runApp(MyApp(initialThemeController: themeController, initialLocale: savedLocale));
}

class MyApp extends StatelessWidget {
  final ThemeController initialThemeController;
  final Locale initialLocale;

  const MyApp({
    super.key,
    required this.initialThemeController,
    required this.initialLocale,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DQ',
          translations: AppTranslations(),
          locale: Get.find<LanguageController>().currentLocale.value,
          fallbackLocale: AppLocales.english,
          theme: initialThemeController.isGreenTheme.value
              ? AppTheme.green
              : AppTheme.light,
          home: _getInitialPage(),
        ));
  }

  Widget _getInitialPage() {
    final auth = HiveManager.get(DbTable.auth, 'current');
    if (auth != null && auth['isLoggedIn'] == true) {
      return const Bottomnavigation();
    }
    return const LoginPage();
  }
}
