import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/usecase/get_my_orders_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final GetMyOrdersUseCase getMyOrdersUseCase;

  OrderController({required this.getMyOrdersUseCase});

  final RxList<OrderEntity> orders = <OrderEntity>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final result = await getMyOrdersUseCase.execute();
      orders.value = result;
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not load orders. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
