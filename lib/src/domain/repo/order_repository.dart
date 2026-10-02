import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';

abstract class OrderRepository {
  Future<RazorpayOrderEntity> createRazorpayOrder({
    required String storeId,
    required List<CartItemEntity> items,
    String? discountCode,
  });

  /// Only the Razorpay proof of payment — the server builds the order.
  Future<OrderEntity> createOrder({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  Future<List<OrderEntity>> getMyOrders();

  Future<List<String>> validateCartStock({
    required String storeId,
    required List<CartItemEntity> items,
  });

  Future<OrderEntity> getOrderById(String orderId);
}
