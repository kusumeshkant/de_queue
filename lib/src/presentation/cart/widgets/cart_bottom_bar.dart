import 'dart:ui';
import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
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
                      color: AppColors.errorBorder, width: 1.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.errorBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.errorSubtle,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.errorBorder, width: 2),
                  ),
                  child: const Icon(Icons.payment_rounded,
                      color: AppColors.error, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  'Payment Failed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message.replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: tc.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 28),
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
                      Get.back();
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
                    child: const Text('Close', style: TextStyle(fontSize: 15)),
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

    return Obx(() {
      // ── Savings calculation ──────────────────────────────────────────────
      double totalSaved = 0;
      for (final item in c.items) {
        if (item.mrp != null && item.mrp! > item.price) {
          totalSaved += (item.mrp! - item.price) * item.quantity;
        }
      }
      final hasSavings = totalSaved > 0;

      // ── Store name ───────────────────────────────────────────────────────
      final storeName = Get.isRegistered<DashboardController>()
          ? Get.find<DashboardController>().selectedStoreName.value
          : '';

      return ClipRRect(
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
                // ── Paying at store ────────────────────────────────────────
                if (storeName.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.store_rounded,
                          size: 13,
                          color: tc.textSecondary.withValues(alpha: 0.7)),
                      const SizedBox(width: 5),
                      Text(
                        'Paying at $storeName',
                        style: TextStyle(
                          fontSize: 12,
                          color: tc.textSecondary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(height: 1, color: tc.cardBorder),
                  const SizedBox(height: 10),
                ],

                // ── Discount code input ────────────────────────────────────
                Obx(() {
                  if (c.discountResult.value != null) {
                    // Code applied — show summary with remove button
                    final result = c.discountResult.value!;
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF00C853)
                                    .withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF00C853), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Code applied — '
                                  '${(result['discountPercent'] as num).toStringAsFixed(0)}% off'
                                  ' by ${result['generatedByName'] ?? 'staff'}',
                                  style: const TextStyle(
                                      color: Color(0xFF00C853),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              GestureDetector(
                                onTap: c.removeDiscount,
                                child: const Icon(Icons.close_rounded,
                                    color: Color(0xFF00C853), size: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }
                  // No code applied — show input field
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: c.discountCodeCtrl,
                              textCapitalization: TextCapitalization.characters,
                              style: TextStyle(
                                  color: tc.textPrimary,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'Discount code (from staff)',
                                hintStyle: TextStyle(
                                    color: tc.textSecondary,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13),
                                prefixIcon: Icon(Icons.percent_rounded,
                                    color: tc.textSecondary, size: 18),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: tc.cardBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: tc.cardBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: tc.primary, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(() => SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: tc.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                  ),
                                  onPressed: c.isValidatingCode.value
                                      ? null
                                      : c.validateAndApplyDiscount,
                                  child: c.isValidatingCode.value
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Text('Apply',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }),

                // ── Price breakdown ────────────────────────────────────────
                _row(tc, AppKeys.subtotal.tr,
                    '₹${c.subtotal.toStringAsFixed(0)}'),
                const SizedBox(height: 4),
                _row(tc, 'GST (18%)', '₹${c.tax.toStringAsFixed(0)}'),

                // MRP savings row
                if (hasSavings) ...[
                  const SizedBox(height: 4),
                  _row(
                    tc,
                    'You save',
                    '−₹${totalSaved.toStringAsFixed(0)}',
                    valueColor: const Color(0xFF00C853),
                  ),
                ],

                // Discount code savings row
                Obx(() => c.discountResult.value != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _row(
                          tc,
                          'Discount (${(c.discountResult.value!['discountPercent'] as num).toStringAsFixed(0)}%)',
                          '−₹${c.discountAmount.toStringAsFixed(0)}',
                          valueColor: const Color(0xFF00C853),
                        ),
                      )
                    : const SizedBox.shrink()),

                const SizedBox(height: 8),
                Divider(height: 1, color: tc.cardBorder),
                const SizedBox(height: 8),

                _row(tc, AppKeys.total.tr,
                    '₹${c.effectiveGrandTotal.toStringAsFixed(0)}',
                    bold: true, valueColor: tc.primary),

                const SizedBox(height: 14),

                // ── Checkout button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: c.isCheckingOut.value
                      ? Center(
                          child:
                              CircularProgressIndicator(color: tc.primary))
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
                            onError: (msg) => _showPaymentFailedSheet(msg),
                          ),
                        ),
                ),

                const SizedBox(height: 10),

                // ── Security badge ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded,
                        size: 12,
                        color: tc.textSecondary.withValues(alpha: 0.55)),
                    const SizedBox(width: 4),
                    Text(
                      'Payments secured by Razorpay',
                      style: TextStyle(
                        fontSize: 11,
                        color: tc.textSecondary.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _row(
    ThemeController tc,
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: tc.textSecondary,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? tc.textPrimary,
          ),
        ),
      ],
    );
  }
}
