import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/widgets/app_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quantity_button.dart';

class CartItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double price;
  final double? mrp;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;

  const CartItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    this.mrp,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  bool get _hasDiscount => mrp != null && mrp! > price;
  double get _savedPerItem => _hasDiscount ? (mrp! - price) : 0;
  double get _savedTotal => _savedPerItem * quantity;

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product icon
              Obx(() => Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: tc.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.shopping_bag_outlined,
                        size: 28, color: tc.primary),
                  )),

              const SizedBox(width: 12),

              // Name + subtitle + price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Obx(() => Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: tc.textPrimary,
                                  height: 1.3,
                                ),
                              )),
                        ),
                        if (onRemove != null)
                          GestureDetector(
                            onTap: onRemove,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(Icons.close,
                                  size: 18, color: tc.textSecondary),
                            ),
                          ),
                      ],
                    ),

                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Obx(() => Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: tc.textSecondary, fontSize: 12),
                          )),
                    ],

                    const SizedBox(height: 8),

                    // Price row: sale price + MRP strikethrough
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Obx(() => Text(
                              '₹${price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: tc.primary,
                              ),
                            )),
                        if (_hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            '₹${mrp!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Quantity controls
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      QuantityButton(
                          icon: Icons.remove, onTap: onDecrement ?? () {}),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Obx(() => Text(
                              quantity.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: tc.textPrimary,
                              ),
                            )),
                      ),
                      QuantityButton(
                          icon: Icons.add, onTap: onIncrement ?? () {}),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Per-item savings badge — shown only when there's a discount
          if (_hasDiscount) ...[
            const SizedBox(height: AppSpacing.sm),
            DsDiscountBadge(
              label: 'You save ₹${_savedTotal.toStringAsFixed(0)}'
                  '${quantity > 1 ? ' (₹${_savedPerItem.toStringAsFixed(0)} × $quantity)' : ''}',
            ),
          ],
        ],
      ),
    );
  }
}
