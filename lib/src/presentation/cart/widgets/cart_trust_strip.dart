import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "What happens next" 3-step flow strip shown above the checkout bar.
class CartTrustStrip extends StatelessWidget {
  const CartTrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return Obx(() {
      final isDark = tc.isGreenTheme.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Step(
              icon: Icons.payment_rounded,
              label: 'Pay',
              color: tc.primary,
            ),
            _Arrow(color: tc.textSecondary),
            _Step(
              icon: Icons.shopping_bag_outlined,
              label: 'Staff\nPrepares',
              color: tc.primary,
            ),
            _Arrow(color: tc.textSecondary),
            _Step(
              icon: Icons.qr_code_rounded,
              label: 'Show QR\nat Exit',
              color: tc.primary,
            ),
          ],
        ),
      );
    });
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Step({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  final Color color;
  const _Arrow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_forward_ios_rounded,
        size: 12, color: color.withValues(alpha: 0.4));
  }
}
