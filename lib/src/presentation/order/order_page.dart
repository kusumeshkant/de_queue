import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/order/order_controller.dart';
import 'package:dq_app/src/presentation/order/order_detail_page.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/widgets/app_glass_card.dart';
import 'package:dq_app/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OrderController>();
    final tc = Get.find<ThemeController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Obx(() => Text(AppKeys.yourOrders.tr,
              style: TextStyle(color: tc.textPrimary))),
          centerTitle: false,
        ),
        body: Obx(() {
          if (c.isLoading.value) {
            return Center(
                child: CircularProgressIndicator(color: tc.primary));
          }

          if (c.orders.isEmpty) {
            return Center(
              child: Text(
                AppKeys.noOrders.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: tc.textSecondary, fontSize: 15),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: c.loadOrders,
            color: tc.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: c.orders.length,
              itemBuilder: (context, index) =>
                  _OrderCard(order: c.orders[index]),
            ),
          );
        }),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return GestureDetector(
      onTap: () => Get.to(
        () => OrderDetailPage(order: order),
        transition: Transition.rightToLeft,
      ),
      child: AppGlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left — store icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tc.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.receipt_long_rounded, color: tc.primary, size: 20),
            ),
            const SizedBox(width: 12),

            // Middle — store name, date, payment badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.storeName ?? AppKeys.unknownStore.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: tc.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order.formattedDate,
                    style: TextStyle(color: tc.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StatusBadge(status: order.status),
                      const SizedBox(width: 6),
                      _PaymentBadge(paymentStatus: order.paymentStatus),
                    ],
                  ),
                ],
              ),
            ),

            // Right — total + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${order.grandTotal.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: tc.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                  style: TextStyle(color: tc.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Icon(Icons.chevron_right_rounded,
                    color: tc.textSecondary.withValues(alpha: 0.5), size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String paymentStatus;
  const _PaymentBadge({required this.paymentStatus});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(
        paymentStatus == 'success' ? 'completed' : paymentStatus);
    final (icon, label) = switch (paymentStatus.toLowerCase()) {
      'success' => (Icons.verified_rounded, AppKeys.paymentSuccess.tr),
      'failed' => (Icons.error_outline_rounded, AppKeys.payStatusFailed.tr),
      _ => (Icons.schedule_rounded, AppKeys.payStatusPending.tr),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 11),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '${AppKeys.paymentStatus.tr}: $label',
          style: AppTypography.captionBold.copyWith(color: color),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return DsStatusBadge(status: status);
  }
}
