import 'dart:ui';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/dashBoard/navigation_controller.dart';
import 'package:dq_app/src/presentation/order/order_confirmation_page.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'primary_button.dart';

class CartBottomBar extends StatelessWidget {
  const CartBottomBar({super.key});

  void _showPaymentFailedSheet(String message) {
    final tc = Get.find<ThemeController>();
    Get.bottomSheet(
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: BoxDecoration(
              color: tc.cardSurface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                  top: BorderSide(
                      color: Colors.red.withValues(alpha: 0.5), width: 1.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(Icons.payment_rounded,
                      color: Colors.red, size: 30),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Payment Failed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  message.replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 14, color: tc.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 28),

                // Back to Dashboard button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tc.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Get.back(); // close sheet
                      Get.until((r) => r.isFirst);
                      if (Get.isRegistered<NavigationController>()) {
                        Get.find<NavigationController>().goToHome();
                      }
                    },
                    child: const Text('Back to Dashboard',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),

                // Close — stay on cart to retry
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: tc.cardBorder),
                      foregroundColor: tc.textSecondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text('Close',
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CartController>();
    final tc = Get.find<ThemeController>();

    return Obx(() => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
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
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: c.isCheckingOut.value
                        ? Center(
                            child: CircularProgressIndicator(color: tc.primary))
                        : PrimaryButton(
                            title: AppKeys.checkout.tr,
                            onTap: () => c.checkout(
                              onSuccess: (order) {
                                LocalStorage.savePendingOrder(order);
                                Get.to(
                                  () => OrderConfirmationPage(order: order),
                                  transition: Transition.fadeIn,
                                );
                              },
                              onError: (msg) =>
                                  _showPaymentFailedSheet(msg),
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
