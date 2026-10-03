import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/src/utils/responsive/responsive.dart';
import 'package:dq_app/widgets/app_glass_card.dart';
import 'package:dq_app/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dq_app/src/utils/money.dart';
import 'package:dq_app/src/presentation/order/widgets/exit_pass.dart';

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
          padding: EdgeInsets.fromLTRB(context.pagePadding, 8, context.pagePadding, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // ── Exit pass ────────────────────────────────────────────────
              ExitPassCard(order: order, qrSize: 180),
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
                        ExitStatusBadge(order: order),
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
                        formatRupees(order.subtotalBeforeDiscount)),
                    if (order.discountAmount > 0) ...[
                      const SizedBox(height: 6),
                      _totalRow(tc, 'Discount',
                          '−${formatRupees(order.discountAmount)}'),
                    ],
                    const SizedBox(height: 6),
                    _totalRow(
                        tc, 'Tax (18%)', formatRupees(order.tax)),
                    Divider(color: tc.cardBorder, height: 16),
                    _totalRow(
                        tc,
                        'Grand Total',
                        formatRupees(order.grandTotal),
                        bold: true),
                  ],
                ),
              ),
                ],
              ),
            ),
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
                formatRupees((item.price * item.quantity)),
                style: TextStyle(
                    color: tc.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const SizedBox(height: 3),
              Text(
                '${item.quantity} × ${formatRupees(item.price)}',
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
