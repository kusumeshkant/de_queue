import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase({required this.repository});

  /// Turns a verified Razorpay payment into an order. Only the three Razorpay
  /// values are sent; the server builds the order from its own records.
  Future<OrderEntity> execute({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) =>
      repository.createOrder(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
}
