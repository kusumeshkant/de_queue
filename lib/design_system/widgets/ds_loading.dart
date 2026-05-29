import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Loading state widgets for DQ App — theme-aware.
class DsLoading extends StatelessWidget {
  final String? message;

  const DsLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tc = Get.find<ThemeController>();
      final color = tc.primary;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 3,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(message!, style: AppTypography.bodySmall),
            ],
          ],
        ),
      );
    });
  }
}

/// Overlay that dims content while loading.
class DsLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const DsLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x4D000000),
              child: Center(child: DsLoading()),
            ),
          ),
      ],
    );
  }
}
