import 'package:dq_app/core/enums/db_tables_enums.dart';
import 'package:dq_app/core/manager/hive_manager.dart';
import 'package:dq_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final RxBool isGreenTheme = false.obs;

  // Background gradient colors
  List<Color> get bgGradient => isGreenTheme.value
      ? [const Color(0xFF0A1628), const Color(0xFF0D3B2E)]
      : [const Color(0xFFEEF2FF), const Color(0xFFE8F5E9)];

  // Accent / primary color
  Color get primary =>
      isGreenTheme.value ? const Color(0xFF00E676) : const Color(0xFF6C63FF);

  // Text colors
  Color get textPrimary =>
      isGreenTheme.value ? Colors.white : const Color(0xFF1A1A2E);
  Color get textSecondary =>
      isGreenTheme.value ? Colors.white60 : Colors.grey.shade600;

  // Glass card surface
  Color get cardSurface => isGreenTheme.value
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.white.withValues(alpha: 0.75);
  Color get cardBorder => isGreenTheme.value
      ? Colors.white.withValues(alpha: 0.15)
      : Colors.white.withValues(alpha: 0.85);

  void toggle() {
    isGreenTheme.value = !isGreenTheme.value;
    Get.changeTheme(isGreenTheme.value ? AppTheme.green : AppTheme.light);
    HiveManager.put(DbTable.settings, 'theme', {'isGreen': isGreenTheme.value});
  }

  @override
  void onInit() {
    super.onInit();
    final saved = HiveManager.get(DbTable.settings, 'theme');
    if (saved != null) {
      isGreenTheme.value = saved['isGreen'] as bool? ?? false;
    }
  }
}
