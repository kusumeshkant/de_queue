import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/dashBoard/navigation_controller.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/src/utils/responsive/responsive.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';
import 'package:dq_app/widgets/app_glass_card.dart';
import 'package:dq_app/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dq_app/src/utils/money.dart';
import 'package:dq_app/src/presentation/order/widgets/exit_pass.dart';

class OrderConfirmationPage extends StatelessWidget {
  final OrderEntity order;

  const OrderConfirmationPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            AppKeys.orderConfirmed.tr,
            style: TextStyle(color: tc.textPrimary, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(context.pagePadding, 8, context.pagePadding, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.maxContentWidth),
                child: Column(
                  children: [
                // Success icon + heading
                const SizedBox(height: 8),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.successSubtle,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.successBorder, width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  AppKeys.paymentSuccessful.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: tc.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppKeys.showToStaff.tr,
                  style: TextStyle(fontSize: 14, color: tc.textSecondary),
                ),
                const SizedBox(height: 24),

                // Exit pass: QR + typeable code while paid, exit confirmation once exited
                ExitPassCard(order: order, qrSize: context.responsive(200.0, tablet: 220.0, desktop: 240.0)),

                const SizedBox(height: 16),

                // Order summary card
                AppGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store + date header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.storeName ?? 'Store',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: tc.textPrimary,
                            ),
                          ),
                          ExitStatusBadge(order: order),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.formattedDate,
                        style:
                            TextStyle(fontSize: 12, color: tc.textSecondary),
                      ),
                      Divider(color: tc.cardBorder, height: 20),

                      // Items
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(item.name,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: tc.textPrimary)),
                                ),
                                Text(
                                  '${item.quantity} × ${formatRupees(item.price)}',
                                  style: TextStyle(
                                      fontSize: 13, color: tc.textSecondary),
                                ),
                              ],
                            ),
                          )),

                      Divider(color: tc.cardBorder, height: 20),

                      // Totals
                      _summaryRow(tc, AppKeys.orderSubtotal.tr,
                          formatRupees(order.subtotalBeforeDiscount)),
                      const SizedBox(height: 4),
                      _summaryRow(
                          tc, AppKeys.tax.tr, formatRupees(order.tax)),
                      // Discount row — shown only when a code was applied
                      Builder(builder: (_) {
                        final saved = order.discountAmount;
                        if (saved <= 0) return const SizedBox.shrink();
                        return Column(children: [
                          const SizedBox(height: 4),
                          _summaryRow(
                            tc, 'Discount applied',
                            '−${formatRupees(saved)}',
                            valueColor: AppColors.success,
                          ),
                        ]);
                      }),
                      const SizedBox(height: 6),
                      _summaryRow(
                          tc, AppKeys.total.tr, formatRupees(order.grandTotal),
                          bold: true),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Go to Home button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tc.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      await LocalStorage.clearPendingOrder();
                      Get.until((r) => r.isFirst);
                      if (Get.isRegistered<NavigationController>()) {
                        Get.find<NavigationController>().goToHome();
                      }
                    },
                    child: const Text('Go to Home',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(ThemeController tc, String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: bold ? tc.textPrimary : tc.textSecondary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? tc.textPrimary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

