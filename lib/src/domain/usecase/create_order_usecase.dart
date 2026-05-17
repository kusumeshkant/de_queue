import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase({required this.repository});

  Future<OrderEntity> execute({
    required String storeId,
    required List<CartItemEntity> items,
    required double total,
    required double tax,
    required double grandTotal,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    String? discountCode,
  }) =>
      repository.createOrder(
        storeId: storeId,
        items: items,
        total: total,
        tax: tax,
        grandTotal: grandTotal,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        discountCode: discountCode,
      );
}
