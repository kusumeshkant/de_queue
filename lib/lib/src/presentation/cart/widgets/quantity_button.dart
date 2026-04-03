import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const QuantityButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return Obx(() => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 26,
            width: 26,
            decoration: BoxDecoration(
              border: Border.all(color: tc.cardBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: tc.textPrimary),
          ),
        ));
  }
}
