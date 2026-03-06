import 'dart:ui';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreCard extends StatelessWidget {
  final String imageUrl;
  final String storeName;
  final VoidCallback? onTap;

  const StoreCard({
    super.key,
    required this.imageUrl,
    required this.storeName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return Obx(() => GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  color: tc.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tc.cardBorder),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 8,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: tc.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.store_outlined, size: 40, color: tc.primary),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Center(
                          child: Text(
                            storeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: tc.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
