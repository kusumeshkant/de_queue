import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/widgets/app_glass_card.dart';
import 'package:dq_app/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: tc.textPrimary, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Order Details',
            style: TextStyle(
                color: tc.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── QR Code card ─────────────────────────────────────────────
              AppGlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.successSubtle,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.qr_code_rounded,
                              color: AppColors.success, size: 17),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Show QR to Staff',
                                style: TextStyle(
                                    color: tc.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              Text(
                                'Staff scans this to verify & complete your order',
                                style: TextStyle(
                                    color: tc.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

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
                        size: 180,
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
                    const SizedBox(height: 14),

                    // Order ID — copyable
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: order.id));
                        Get.snackbar(
                          '',
                          'Order ID copied',
                          titleText: const SizedBox.shrink(),
                          messageText: const Text('Order ID copied',
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.black87,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: tc.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: tc.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ID: ${order.id}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: tc.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.copy_rounded,
                                size: 13, color: tc.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Order info card ───────────────────────────────────────────
              AppGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.storeName ?? 'Store',
                              style: TextStyle(
                                  color: tc.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.formattedDate,
                              style: TextStyle(
                                  color: tc.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        _StatusBadge(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _PaymentBadge(paymentStatus: order.paymentStatus),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Items section ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 8),
                child: Text(
                  'Items (${order.items.length})',
                  style: TextStyle(
                      color: tc.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              ...order.items.map((item) => _ItemCard(item: item, tc: tc)),
              const SizedBox(height: 14),

              // ── Totals card ───────────────────────────────────────────────
              AppGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _totalRow(tc, 'Subtotal',
                        '₹${order.total.toStringAsFixed(0)}'),
                    const SizedBox(height: 6),
                    _totalRow(
                        tc, 'Tax (18%)', '₹${order.tax.toStringAsFixed(0)}'),
                    Divider(color: tc.cardBorder, height: 16),
                    _totalRow(
                        tc,
                        'Grand Total',
                        '₹${order.grandTotal.toStringAsFixed(0)}',
                        bold: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalRow(ThemeController tc, String label, String value,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: bold ? tc.textPrimary : tc.textSecondary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 15 : 14)),
        Text(value,
            style: TextStyle(
                color: bold ? tc.primary : tc.textPrimary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 16 : 14)),
      ],
    );
  }
}

// ── Item card ─────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final OrderItemEntity item;
  final ThemeController tc;

  const _ItemCard({required this.item, required this.tc});

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left — product icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tc.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.inventory_2_outlined, color: tc.primary, size: 20),
          ),
          const SizedBox(width: 12),

          // Middle — product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  item.name,
                  style: TextStyle(
                      color: tc.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),

                // SKU
                if ((item.sku ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tc.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: tc.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          'SKU: ${item.sku}',
                          style: TextStyle(
                              color: tc.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3),
                        ),
                      ),
                    ],
                  ),
                ],

                // Description
                if ((item.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(color: tc.textSecondary, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Right — qty × price
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                style: TextStyle(
                    color: tc.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const SizedBox(height: 3),
              Text(
                '${item.quantity} × ₹${item.price.toStringAsFixed(0)}',
                style: TextStyle(color: tc.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Badges ────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status.toLowerCase()) {
      'pending' => (AppColors.neutral, Icons.hourglass_empty_rounded, 'Pending'),
      'preparing' => (AppColors.warning, Icons.restaurant_rounded, 'Preparing'),
      'ready' => (AppColors.info, Icons.shopping_bag_rounded, 'Ready'),
      'completed' => (AppColors.success, Icons.check_circle_rounded, 'Confirmed'),
      'cancelled' => (AppColors.error, Icons.cancel_rounded, 'Cancelled'),
      _ => (AppColors.warning, Icons.info_outline_rounded, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String paymentStatus;
  const _PaymentBadge({required this.paymentStatus});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (paymentStatus.toLowerCase()) {
      'success' => (AppColors.success, Icons.verified_rounded, 'Payment: Success'),
      'failed' => (AppColors.error, Icons.error_outline_rounded, 'Payment: Failed'),
      _ => (AppColors.neutral, Icons.schedule_rounded, 'Payment: Pending'),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
