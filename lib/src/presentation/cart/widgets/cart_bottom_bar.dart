import 'dart:ui';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/dashBoard/navigation_controller.dart';
import 'package:dq_app/src/presentation/order/order_binding.dart';
import 'package:dq_app/src/presentation/order/order_page.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'primary_button.dart';

class CartBottomBar extends StatelessWidget {
  const CartBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CartController>();
    final tc = Get.find<ThemeController>();

    return Obx(() => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              decoration: BoxDecoration(
                color: tc.cardSurface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                border: Border(top: BorderSide(color: tc.cardBorder)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(tc, AppKeys.subtotal.tr,
                      '₹${c.subtotal.toStringAsFixed(0)}'),
                  _row(tc, AppKeys.tax.tr, '₹${c.tax.toStringAsFixed(0)}'),
                  _row(tc, AppKeys.total.tr,
                      '₹${c.grandTotal.toStringAsFixed(0)}',
                      bold: true, accent: tc.primary),
                  const SizedBox(height: 10),

                  // Inline failure banner
                  if (c.hasPaymentFailed.value) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c.failureMessage.value,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: c.isCheckingOut.value
                        ? Center(
                            child: CircularProgressIndicator(color: tc.primary))
                        : PrimaryButton(
                            title: c.hasPaymentFailed.value
                                ? AppKeys.retryPayment.tr
                                : AppKeys.checkout.tr,
                            onTap: () => c.checkout(
                              onSuccess: (orderId) {
                                // Navigate back to Home tab
                                Get.find<NavigationController>().goToHome();
                                Get.snackbar(
                                  AppKeys.orderPlaced.tr,
                                  AppKeys.orderSuccess.tr,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 4),
                                  mainButton: TextButton(
                                    onPressed: () => Get.to(
                                      () => const OrderPage(),
                                      binding: OrderBinding(),
                                    ),
                                    child: Text(
                                      AppKeys.viewOrders.tr,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              },
                              onError: (msg) => Get.snackbar(
                                AppKeys.checkoutFailed.tr,
                                msg,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _row(ThemeController tc, String label, String value,
      {bool bold = false, Color? accent}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 15,
                color: tc.textSecondary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 16 : 15,
                fontWeight: FontWeight.bold,
                color: accent ?? tc.textPrimary)),
      ],
    );
  }
}
