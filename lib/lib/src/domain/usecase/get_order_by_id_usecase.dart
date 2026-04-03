import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';

class GetOrderByIdUseCase {
  final OrderRepository repository;

  GetOrderByIdUseCase({required this.repository});

  Future<OrderEntity> execute(String orderId) =>
      repository.getOrderById(orderId);
}
