import 'package:dq_app/src/utils/money.dart';
class OrderItemEntity {
  final String barcode;
  final String name;
  final double price;
  final int quantity;
  final String? sku;
  final String? description;

  const OrderItemEntity({
    required this.barcode,
    required this.name,
    required this.price,
    required this.quantity,
    this.sku,
    this.description,
  });
}

class OrderEntity {
  final String id;
  final String? storeName;
  /// Discounted subtotal (server S-7: total + tax == grandTotal).
  final double total;

  /// Staff discount the server applied to the subtotal; 0 when none.
  final double discountAmount;
  final double tax;
  final double grandTotal;
  final String status;
  final String paymentStatus;
  final String createdAt;
  final List<OrderItemEntity> items;

  /// What the exit QR encodes ("DQX1:<code>", or the order id for orders
  /// placed before exit codes). Sent only to the order's owner, and only
  /// while the order can still exit.
  final String? exitQr;

  /// When staff let the customer out (ISO-8601); null until then.
  final String? exitedAt;

  const OrderEntity({
    required this.id,
    this.storeName,
    required this.total,
    this.discountAmount = 0,
    required this.tax,
    required this.grandTotal,
    required this.status,
    this.paymentStatus = 'success',
    required this.createdAt,
    required this.items,
    this.exitQr,
    this.exitedAt,
  });

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  /// Exited at the door. Orders completed under the old status flow count too.
  bool get isExited => exitedAt != null || status.toLowerCase() == 'completed';

  /// Paid and still in the store: show the exit QR.
  bool get canExit => !isExited && !isCancelled;

  /// QR content while the order can exit, else null.
  String? get qrData => canExit ? (exitQr ?? id) : null;

  /// The code after "DQX1:", or null for orders placed before exit codes.
  String? get exitCode =>
      (exitQr != null && exitQr!.startsWith('DQX1:')) ? exitQr!.substring(5) : null;

  /// "DQX1: XECZ 08dI Un6U SvcG mPjC NQ" — easy to read out and type.
  String? get exitCodeGrouped {
    final c = exitCode;
    if (c == null) return null;
    final groups = [for (var i = 0; i < c.length; i += 4) c.substring(i, i + 4 > c.length ? c.length : i + 4)];
    return 'DQX1: ${groups.join(' ')}';
  }

  /// "12:24 on 3/10/2026" in local time.
  String? get formattedExitedAt {
    final d = exitedAt == null ? null : DateTime.tryParse(exitedAt!)?.toLocal();
    if (d == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)} on ${d.day}/${d.month}/${d.year}';
  }

  /// Subtotal before the staff discount, in exact paise.
  double get subtotalBeforeDiscount => (toPaise(total) + toPaise(discountAmount)) / 100;

  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt;
    }
  }
}

class RazorpayOrderEntity {
  final String id;
  final int amount;
  final String currency;

  /// Razorpay key the server created this order with — checkout must use it.
  /// Null only against a backend older than A3.
  final String? keyId;

  const RazorpayOrderEntity({
    required this.id,
    required this.amount,
    required this.currency,
    this.keyId,
  });
}
