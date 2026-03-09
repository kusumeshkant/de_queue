import 'dart:ui';
import 'package:dq_app/core/enums/db_tables_enums.dart';
import 'package:dq_app/core/manager/hive_manager.dart';
import 'package:dq_app/src/constants/app_config.dart';
import 'package:dq_app/src/l10n/language_controller.dart';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/auth/login/login_page.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/presentation/dashBoard/navigation_controller.dart';
import 'package:dq_app/src/presentation/order/order_binding.dart';
import 'package:dq_app/src/presentation/order/order_page.dart';
import 'package:dq_app/src/presentation/profile/profile_binding.dart';
import 'package:dq_app/src/presentation/profile/profile_page.dart';
import 'package:dq_app/src/service_core/networks/graphql_client_provider.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/widgets/themed_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    final lc = Get.find<LanguageController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 50),
            Obx(() => _buildSectionTitle(AppKeys.setting.tr, tc)),
            Obx(() => _buildSettingsGroup(tc, [
                  _buildSettingsTile(
                    tc: tc,
                    icon: Icons.person_outline,
                    title: AppKeys.profile.tr,
                    onTap: () {
                      Get.to(() => const ProfilePage(), binding: ProfileBinding());
                    },
                  ),
                  _buildDivider(tc),
                  _buildSettingsTile(
                    tc: tc,
                    icon: Icons.receipt_long_outlined,
                    title: AppKeys.yourOrders.tr,
                    onTap: () {
                      Get.to(() => const OrderPage(), binding: OrderBinding());
                    },
                  ),
                  _buildDivider(tc),
                  _buildSwitchTile(
                    tc: tc,
                    icon: Icons.palette_outlined,
                    title: 'Green Theme',
                    value: tc.isGreenTheme.value,
                    onChanged: (_) => tc.toggle(),
                  ),
                  _buildDivider(tc),
                  _buildLanguageTile(tc, lc),
                ])),
            const SizedBox(height: 25),
            Obx(() => _buildSectionTitle(AppKeys.account.tr, tc)),
            Obx(() => _buildSettingsGroup(tc, [
                  _buildSettingsTile(
                    tc: tc,
                    icon: Icons.phone_outlined,
                    title: AppKeys.phoneNumber.tr,
                    onTap: () {},
                  ),
                  _buildDivider(tc),
                  _buildSettingsTile(
                    tc: tc,
                    icon: Icons.email_outlined,
                    title: AppKeys.email.tr,
                    onTap: () {},
                  ),
                  _buildDivider(tc),
                  _buildSettingsTile(
                    tc: tc,
                    icon: Icons.logout,
                    title: AppKeys.signOut.tr,
                    onTap: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                      } catch (_) {}
                      await HiveManager.clear(DbTable.auth);
                      await GraphQLClientProvider.init(
                        baseUrl: AppConfig.graphqlEndpoint,
                      );
                      // Reset nav to home so next login starts at Dashboard
                      try {
                        Get.find<NavigationController>().goToHome();
                      } catch (_) {}
                      // Delete so next login creates a fresh controller
                      // (isStoreConfirmed = false → store confirmation shows)
                      Get.delete<DashboardController>(force: true);
                      Get.offAll(() => const LoginPage());
                    },
                  ),
                ])),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(ThemeController tc, LanguageController lc) {
    return Obx(() => ListTile(
          leading: Icon(Icons.language, color: tc.textSecondary),
          title: Text(AppKeys.language.tr, style: TextStyle(color: tc.textPrimary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lc.isCurrentLocale(AppLocales.english)
                    ? AppKeys.langEnglish.tr
                    : AppKeys.langHindi.tr,
                style: TextStyle(color: tc.textSecondary, fontSize: 13),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: tc.textSecondary),
            ],
          ),
          onTap: () => _showLanguageDialog(tc, lc),
        ));
  }

  void _showLanguageDialog(ThemeController tc, LanguageController lc) {
    Get.dialog(
      Obx(() => AlertDialog(
            backgroundColor: tc.cardSurface.withValues(alpha: 0.95),
            title: Text(
              AppKeys.selectLanguage.tr,
              style: TextStyle(color: tc.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppLocales.supported.map((entry) {
                final isSelected = lc.isCurrentLocale(entry.locale);
                return ListTile(
                  onTap: () {
                    lc.changeLocale(entry.locale);
                    Get.back();
                  },
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? tc.primary : tc.textSecondary,
                  ),
                  title: Text(
                    entry.nameKey.tr,
                    style: TextStyle(
                      color: tc.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
    );
  }

  Widget _buildSectionTitle(String title, ThemeController tc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: tc.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeController tc) {
    return Divider(height: 1, color: tc.cardBorder);
  }

  Widget _buildSettingsGroup(ThemeController tc, List<Widget> children) {
    final isDark = tc.isGreenTheme.value;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.72),
                      Colors.white.withValues(alpha: 0.44),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.90),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required ThemeController tc,
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: tc.textSecondary),
      title: Text(title, style: TextStyle(color: tc.textPrimary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value, style: TextStyle(color: tc.textSecondary)),
          Icon(Icons.chevron_right, color: tc.textSecondary),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required ThemeController tc,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: tc.textSecondary),
      title: Text(title, style: TextStyle(color: tc.textPrimary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: tc.primary,
      ),
    );
  }
}
