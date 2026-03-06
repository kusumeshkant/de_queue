import 'package:dq_app/src/data/datasources/remote/order_remote_ds.dart';
import 'package:dq_app/src/data/repo_impl/order_repository_impl.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';
import 'package:dq_app/src/domain/usecase/get_my_orders_usecase.dart';
import 'package:dq_app/src/presentation/order/order_controller.dart';
import 'package:get/get.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderRemoteDataSource());
    Get.lazyPut<OrderRepository>(
        () => OrderRepositoryImpl(remote: Get.find()));
    Get.lazyPut(() => GetMyOrdersUseCase(repository: Get.find()));
    Get.lazyPut(
        () => OrderController(getMyOrdersUseCase: Get.find()));
  }
}
