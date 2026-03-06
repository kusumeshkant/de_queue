import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/widgets/app_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quantity_button.dart';

class CartItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double price;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;

  const CartItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: tc.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(Icons.shopping_bag_outlined, size: 28, color: tc.primary),
              )),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: tc.textPrimary),
                          )),
                    ),
                    if (onRemove != null)
                      GestureDetector(
                        onTap: onRemove,
                        child: Icon(Icons.close,
                            size: 18, color: tc.textSecondary),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Obx(() => Text(subtitle,
                    style: TextStyle(color: tc.textSecondary, fontSize: 12))),
                const SizedBox(height: 6),
                Obx(() => Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: tc.primary),
                    )),
              ],
            ),
          ),

          Row(
            children: [
              QuantityButton(icon: Icons.remove, onTap: onDecrement ?? () {}),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                child: Obx(() => Text(quantity.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: tc.textPrimary))),
              ),
              QuantityButton(icon: Icons.add, onTap: onIncrement ?? () {}),
            ],
          ),
        ],
      ),
    );
  }
}
