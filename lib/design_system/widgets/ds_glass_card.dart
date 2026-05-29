import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_shadows.dart';

/// Design-system glass card — theme-aware, works on both light and dark themes.
///
/// Automatically reads ThemeController to choose the correct surface color.
///
/// Usage:
///   DsGlassCard(child: MyContent())
class DsGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? borderRadius;

  const DsGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    final radius = borderRadius ?? AppRadius.card;

    return Obx(() {
      final isDark = tc.isGreenTheme.value;
      final surface =
          isDark ? AppColorsDark.cardSurface : AppColorsLight.cardSurface;
      final border =
          isDark ? AppColorsDark.cardBorder : AppColorsLight.cardBorder;
      final shadows =
          isDark ? AppShadowsDark.glassCard : AppShadowsLight.glassCard;

      return Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadows,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter:
                ImageFilter.blur(sigmaX: AppBlur.glassCard, sigmaY: AppBlur.glassCard),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: border),
              ),
              child: child,
            ),
          ),
        ),
      );
    });
  }
}
