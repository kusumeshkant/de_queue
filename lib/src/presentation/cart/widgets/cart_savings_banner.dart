import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Green savings banner — shown only when at least one item has MRP > price.
class CartSavingsBanner extends StatelessWidget {
  const CartSavingsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CartController>();

    return Obx(() {
      double totalSaved = 0;
      for (final item in c.items) {
        if (item.mrp != null && item.mrp! > item.price) {
          totalSaved += (item.mrp! - item.price) * item.quantity;
        }
      }

      if (totalSaved <= 0) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF00C853).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: const Color(0xFF00C853).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_rounded,
                color: Color(0xFF00C853), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You\'re saving ₹${totalSaved.toStringAsFixed(0)} on this order!',
                style: const TextStyle(
                  color: Color(0xFF00C853),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
