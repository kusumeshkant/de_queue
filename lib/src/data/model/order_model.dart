import 'package:dq_app/src/domain/entity/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.barcode,
    required super.name,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        barcode: json['barcode'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
      );
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    super.storeName,
    required super.total,
    required super.tax,
    required super.grandTotal,
    required super.status,
    super.paymentStatus = 'success',
    required super.createdAt,
    required super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        storeName: json['storeName'] as String?,
        total: (json['total'] as num).toDouble(),
        tax: (json['tax'] as num).toDouble(),
        grandTotal: (json['grandTotal'] as num).toDouble(),
        status: json['status'] as String,
        paymentStatus: json['paymentStatus'] as String? ?? 'success',
        createdAt: json['createdAt'] as String,
        items: (json['items'] as List<dynamic>)
            .map((i) => OrderItemModel.fromJson(i))
            .toList(),
      );
}
