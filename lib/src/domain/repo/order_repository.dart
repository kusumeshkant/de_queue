import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';

abstract class OrderRepository {
  Future<RazorpayOrderEntity> createRazorpayOrder(double amount);

  Future<OrderEntity> createOrder({
    required String storeId,
    required List<CartItemEntity> items,
    required double total,
    required double tax,
    required double grandTotal,
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
