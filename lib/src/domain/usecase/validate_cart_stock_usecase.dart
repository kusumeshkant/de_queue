import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';

class ValidateCartStockUseCase {
  final OrderRepository repository;

  ValidateCartStockUseCase({required this.repository});

  Future<List<String>> execute(String storeId, List<CartItemEntity> items) =>
      repository.validateCartStock(storeId: storeId, items: items);
}
