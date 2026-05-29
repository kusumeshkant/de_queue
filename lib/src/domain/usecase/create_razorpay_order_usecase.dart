import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';

class CreateRazorpayOrderUseCase {
  final OrderRepository repository;

  CreateRazorpayOrderUseCase({required this.repository});

  Future<RazorpayOrderEntity> execute({
    required String storeId,
    required List<CartItemEntity> items,
    String? discountCode,
  }) =>
      repository.createRazorpayOrder(
        storeId: storeId,
        items: items,
        discountCode: discountCode,
      );
}
