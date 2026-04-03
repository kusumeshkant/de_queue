import 'dart:ui';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NearbyStoreTitleTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final VoidCallback? onTap;
  final IconData? icon;

  const NearbyStoreTitleTile({
    super.key,
    required this.title,
    required this.subTitle,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return Obx(() => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tc.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tc.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (icon != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: tc.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: tc.primary),
                      ),
                    if (icon != null) const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: tc.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subTitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: tc.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14, color: tc.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
