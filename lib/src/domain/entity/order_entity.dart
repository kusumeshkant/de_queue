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
  final double total;
  final double tax;
  final double grandTotal;
  final String status;
  final String paymentStatus;
  final String createdAt;
  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    this.storeName,
    required this.total,
    required this.tax,
    required this.grandTotal,
    required this.status,
    this.paymentStatus = 'success',
    required this.createdAt,
    required this.items,
  });

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

  const RazorpayOrderEntity({
    required this.id,
    required this.amount,
    required this.currency,
  });
}
