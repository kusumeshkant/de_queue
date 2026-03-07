import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/order/order_binding.dart';
import 'package:dq_app/src/presentation/order/order_page.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/widgets/app_glass_card.dart';
import 'package:dq_app/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                // Success icon + heading
                const SizedBox(height: 8),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.green.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.green, size: 36),
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

                // QR Code card
                AppGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // QR code
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: order.id,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Order ID row
                      Text(
                        AppKeys.orderIdLabel.tr,
                        style: TextStyle(
                            fontSize: 12,
                            color: tc.textSecondary,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: order.id));
                          Get.snackbar(
                            '',
                            'Order ID copied',
                            titleText: const SizedBox.shrink(),
                            messageText: Text(
                              AppKeys.orderIdCopied.tr,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.black87,
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              order.id,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: tc.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.copy_rounded,
                                size: 14, color: tc.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

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
                          _StatusBadge(status: order.status),
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
                                  '${item.quantity} × ₹${item.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontSize: 13, color: tc.textSecondary),
                                ),
                              ],
                            ),
                          )),

                      Divider(color: tc.cardBorder, height: 20),

                      // Totals
                      _summaryRow(tc, AppKeys.orderSubtotal.tr,
                          '₹${order.total.toStringAsFixed(0)}'),
                      const SizedBox(height: 4),
                      _summaryRow(
                          tc, AppKeys.tax.tr, '₹${order.tax.toStringAsFixed(0)}'),
                      const SizedBox(height: 6),
                      _summaryRow(
                          tc, AppKeys.total.tr, '₹${order.grandTotal.toStringAsFixed(0)}',
                          bold: true),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Done button
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
                    onPressed: () => Get.offAll(
                      () => const OrderPage(),
                      binding: OrderBinding(),
                    ),
                    child: Text(AppKeys.viewOrders.tr,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),

                // Dismiss link
                TextButton(
                  onPressed: () => Get.until((r) => r.isFirst),
                  child: Text(AppKeys.backToHome.tr,
                      style: TextStyle(color: tc.textSecondary, fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(ThemeController tc, String label, String value,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: bold ? tc.textPrimary : tc.textSecondary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: tc.textPrimary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status.toLowerCase()) {
      'pending' => (Colors.grey.shade500, 'Pending'),
      'preparing' => (Colors.orange.shade600, 'Preparing'),
      'ready' => (Colors.blue.shade500, 'Ready'),
      'completed' => (Colors.green.shade600, 'Completed'),
      'cancelled' => (Colors.red.shade600, 'Cancelled'),
      _ => (Colors.orange.shade400, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
