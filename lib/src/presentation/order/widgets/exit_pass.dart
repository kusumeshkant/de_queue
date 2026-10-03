import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/widgets/app_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// The customer's exit pass. While the order can exit: the exit QR plus the
/// code as grouped text, so staff can type it if their camera fails. Once
/// the order has exited: the exit confirmation instead (the QR is gone).
class ExitPassCard extends StatelessWidget {
  final OrderEntity order;
  final double qrSize;

  const ExitPassCard({super.key, required this.order, this.qrSize = 200});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    if (order.isExited) {
      return AppGlassCard(
        key: const Key('exit-pass-exited'),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.success, size: 56),
            const SizedBox(height: 10),
            Text('Exited',
                style: TextStyle(color: tc.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              order.formattedExitedAt == null ? 'Checked out at the exit.' : 'Exited at ${order.formattedExitedAt}',
              key: const Key('exit-pass-exited-at'),
              textAlign: TextAlign.center,
              style: TextStyle(color: tc.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (order.isCancelled) {
      return AppGlassCard(
        key: const Key('exit-pass-cancelled'),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.cancel_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 8),
            Text('This order was cancelled',
                style: TextStyle(color: tc.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    final code = order.exitCodeGrouped;
    return AppGlassCard(
      key: const Key('exit-pass-open'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Paid · show this at the exit',
              key: const Key('exit-pass-status'),
              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Staff scan it and check your bag.', style: TextStyle(color: tc.textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: QrImageView(
              key: const Key('exit-pass-qr'),
              data: order.qrData!,
              version: QrVersions.auto,
              size: qrSize,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
            ),
          ),
          const SizedBox(height: 14),
          Text(code != null ? 'Exit code' : 'Order ID',
              style: TextStyle(fontSize: 12, color: tc.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: order.qrData!));
              Get.snackbar('', '',
                  titleText: const SizedBox.shrink(),
                  messageText: Text(code != null ? 'Exit code copied' : 'Order ID copied',
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.black87,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    code ?? order.id,
                    key: const Key('exit-pass-code'),
                    textAlign: TextAlign.center,
                    // Exit codes use only 0-9 and A-Z without I, L, O, U, so no two
                    // characters look alike; bold, wide spacing and fixed-width digits
                    // make the groups easy to read out and type.
                    style: TextStyle(
                      fontSize: code != null ? 18 : 13,
                      fontWeight: FontWeight.w800,
                      color: tc.primary,
                      letterSpacing: code != null ? 2.0 : 0.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.copy_rounded, size: 14, color: tc.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Order status as the customer understands it.
class ExitStatusBadge extends StatelessWidget {
  final OrderEntity order;
  const ExitStatusBadge({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = order.isExited
        ? (AppColors.success, Icons.check_circle_rounded, 'Exited')
        : order.isCancelled
            ? (AppColors.error, Icons.cancel_rounded, 'Cancelled')
            : (AppColors.info, Icons.qr_code_rounded, 'Paid · show at exit');
    return Container(
      key: Key('exit-status-${order.id}'),
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
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
