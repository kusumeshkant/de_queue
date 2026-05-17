import 'dart:ui';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_bottom_bar.dart';
import 'widgets/cart_savings_banner.dart';
import 'widgets/cart_trust_strip.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CartController>();
    final tc = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const SizedBox(height: 52),

          // ── Glassy header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() {
              final isDark = tc.isGreenTheme.value;
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: 0.10),
                                Colors.white.withValues(alpha: 0.04),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.72),
                                Colors.white.withValues(alpha: 0.44),
                              ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.90),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppKeys.myCart.tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: tc.textPrimary,
                          ),
                        ),
                        Text(
                          '${c.totalItemCount} ${AppKeys.items.tr}',
                          style: TextStyle(
                              color: tc.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Obx(() {
              if (c.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 72,
                          color: tc.textSecondary.withValues(alpha: 0.35)),
                      const SizedBox(height: 16),
                      Text(
                        AppKeys.cartEmpty.tr,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: tc.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan a product barcode to add items',
                        style: TextStyle(
                            fontSize: 13, color: tc.textSecondary),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: c.items.length,
                itemBuilder: (context, index) {
                  final item = c.items[index];
                  return CartItemCard(
                    title: item.name,
                    subtitle: item.subtitle,
                    price: item.price,
                    mrp: item.mrp,
                    quantity: item.quantity,
                    onIncrement: () => c.incrementQuantity(item.barcode),
                    onDecrement: () => c.decrementQuantity(item.barcode),
                    onRemove: () => c.removeItem(item.barcode),
                  );
                },
              );
            }),
          ),
          Obx(() => c.items.isNotEmpty
              ? const CartSavingsBanner()
              : const SizedBox.shrink()),
          Obx(() => c.items.isNotEmpty
              ? const CartTrustStrip()
              : const SizedBox.shrink()),
          Obx(() => c.items.isNotEmpty
              ? const CartBottomBar()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
