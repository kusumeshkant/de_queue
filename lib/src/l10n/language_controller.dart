import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translation_keys.dart';

/// Supported app locales.
/// To add a new language: add an entry here and in [AppTranslations].
class AppLocales {
  static const english = Locale('en', 'US');
  static const hindi = Locale('hi', 'IN');

  /// All supported locales with their display names.
  /// The display name key maps to [AppKeys.langXxx] for translation support.
  static const List<({Locale locale, String nameKey})> supported = [
    (locale: english, nameKey: AppKeys.langEnglish),
    (locale: hindi, nameKey: AppKeys.langHindi),
  ];

  static const _prefKey = 'app_locale';

  static Future<Locale> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved == null) return english;
    final parts = saved.split('_');
    if (parts.length < 2) return english;
    return Locale(parts[0], parts[1]);
  }

  static Future<void> save(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, '${locale.languageCode}_${locale.countryCode}');
  }
}

class LanguageController extends GetxController {
  final currentLocale = AppLocales.english.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final locale = await AppLocales.loadSaved();
    currentLocale.value = locale;
    Get.updateLocale(locale);
  }

  Future<void> changeLocale(Locale locale) async {
    currentLocale.value = locale;
    Get.updateLocale(locale);
    await AppLocales.save(locale);
  }

  bool isCurrentLocale(Locale locale) =>
      currentLocale.value.languageCode == locale.languageCode;
}
