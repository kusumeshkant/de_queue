import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// Centralized status badge — replaces all inline status/payment color logic.
///
/// Works on both light and dark themes — semantic colors are theme-independent.
///
/// Usage:
///   DsStatusBadge(status: order.status)
///   DsStatusBadge.payment(status: 'paid')
class DsStatusBadge extends StatelessWidget {
  final String status;
  final IconData? icon;
  final bool compact;

  const DsStatusBadge({
    super.key,
    required this.status,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    final subtle = AppColors.statusSubtle(status);
    final border = AppColors.statusBorder(status);
    final label = _label(status);
    final defaultIcon = _icon(status);

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs, vertical: AppSpacing.xxs)
          : const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: subtle,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? defaultIcon, size: 12, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.badge.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  static String _label(String status) => switch (status.toLowerCase()) {
        'pending' => 'Pending',
        'preparing' => 'Preparing',
        'ready' => 'Ready',
        'completed' => 'Completed',
        'cancelled' => 'Cancelled',
        'paid' => 'Paid',
        'failed' => 'Failed',
        _ => status,
      };

  static IconData _icon(String status) => switch (status.toLowerCase()) {
        'pending' => Icons.schedule_outlined,
        'preparing' => Icons.local_fire_department_outlined,
        'ready' => Icons.done_outline,
        'completed' || 'paid' => Icons.check_circle_outline,
        'cancelled' || 'failed' => Icons.cancel_outlined,
        _ => Icons.info_outline,
      };
}

/// Discount/savings badge — for cart and product cards.
class DsDiscountBadge extends StatelessWidget {
  final String label;

  const DsDiscountBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.successSubtle,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.successBorder),
      ),
      child: Text(
        label,
        style: AppTypography.badge.copyWith(color: AppColors.success),
      ),
    );
  }
}
