import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';

class GetMyOrdersUseCase {
  final OrderRepository repository;

  GetMyOrdersUseCase({required this.repository});

  Future<List<OrderEntity>> execute() => repository.getMyOrders();
}
