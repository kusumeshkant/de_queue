import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/order/order_controller.dart';
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

    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.storeName ?? AppKeys.unknownStore.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: tc.textPrimary),
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.formattedDate,
                    style: TextStyle(color: tc.textSecondary, fontSize: 12)),
                const SizedBox(height: 5),
                _PaymentBadge(paymentStatus: order.paymentStatus),
              ],
            ),
          ),
          trailing: Text(
            '₹${order.grandTotal.toStringAsFixed(0)}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: tc.primary),
          ),
          children: [
            Divider(color: tc.cardBorder),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(item.name,
                              style: TextStyle(
                                  fontSize: 13, color: tc.textPrimary))),
                      Text(
                        '${item.quantity} × ₹${item.price.toStringAsFixed(0)}',
                        style:
                            TextStyle(color: tc.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )),
            Divider(color: tc.cardBorder),
            _summaryRow(tc, AppKeys.orderSubtotal.tr, '₹${order.total.toStringAsFixed(0)}'),
            const SizedBox(height: 4),
            _summaryRow(tc, AppKeys.tax.tr, '₹${order.tax.toStringAsFixed(0)}'),
            const SizedBox(height: 6),
            _summaryRow(tc, AppKeys.total.tr, '₹${order.grandTotal.toStringAsFixed(0)}',
                bold: true),
            const SizedBox(height: 8),
          ],
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

class _PaymentBadge extends StatelessWidget {
  final String paymentStatus;
  const _PaymentBadge({required this.paymentStatus});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (paymentStatus.toLowerCase()) {
      'success' => (Colors.green.shade600,  Icons.verified_rounded,       AppKeys.paymentSuccess.tr),
      'failed'  => (Colors.red.shade600,    Icons.error_outline_rounded,  AppKeys.payStatusFailed.tr),
      _         => (Colors.grey.shade500,   Icons.schedule_rounded,       AppKeys.payStatusPending.tr),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 11),
        const SizedBox(width: 4),
        Text(
          '${AppKeys.paymentStatus.tr}: $label',
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600),
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
    final (color, icon, label) = switch (status.toLowerCase()) {
      'pending'    => (Colors.grey.shade500,    Icons.hourglass_empty_rounded,  AppKeys.statusPending.tr),
      'preparing'  => (Colors.orange.shade600,  Icons.restaurant_rounded,       AppKeys.statusPreparing.tr),
      'ready'      => (Colors.blue.shade500,    Icons.shopping_bag_rounded,     AppKeys.statusReady.tr),
      'completed'  => (Colors.green.shade600,   Icons.check_circle_rounded,     AppKeys.statusConfirmed.tr),
      'cancelled'  => (Colors.red.shade600,     Icons.cancel_rounded,           AppKeys.statusCancelled.tr),
      _            => (Colors.orange.shade400,  Icons.info_outline_rounded,     status),
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
