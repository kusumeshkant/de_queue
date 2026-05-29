import 'package:dq_app/src/data/datasources/remote/order_remote_ds.dart';
import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remote;

  OrderRepositoryImpl({required this.remote});

  @override
  Future<RazorpayOrderEntity> createRazorpayOrder({
    required String storeId,
    required List<CartItemEntity> items,
    String? discountCode,
  }) =>
      remote.createRazorpayOrder(
        storeId: storeId,
        items: items,
        discountCode: discountCode,
      );

  @override
  Future<OrderEntity> createOrder({
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
      remote.createOrder(
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

  @override
  Future<List<OrderEntity>> getMyOrders() => remote.getMyOrders();

  @override
  Future<List<String>> validateCartStock({
    required String storeId,
    required List<CartItemEntity> items,
  }) => remote.validateCartStock(storeId: storeId, items: items);

  @override
  Future<OrderEntity> getOrderById(String orderId) =>
      remote.getOrderById(orderId);
}
