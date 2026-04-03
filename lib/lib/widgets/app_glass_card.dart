import 'dart:ui';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Theme-aware glass card — use this throughout the app (not on auth pages).
class AppGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  const AppGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() => Container(
          margin: margin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: padding ?? const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: tc.cardSurface,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: tc.cardBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: tc.isGreenTheme.value ? 0.3 : 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ));
  }
}
