import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/usecase/get_product_by_barcode_usecase.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScannerController extends GetxController {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;

  ScannerController({required this.getProductByBarcodeUseCase});

  final RxBool isScanningPaused = false.obs;

  Future<void> onBarcodeDetected(String barcode) async {
    if (isScanningPaused.value) return;
    isScanningPaused.value = true;

    try {
      final dashboard = Get.find<DashboardController>();
      final storeId = dashboard.selectedStoreId.value;

      if (storeId.isEmpty) {
        Get.snackbar(
          'No Store Selected',
          'Please select a store before scanning.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final product =
          await getProductByBarcodeUseCase.execute(barcode, storeId);

      if (product == null) {
        // Product not in this store's inventory — reject it
        Get.snackbar(
          'Not Available',
          'This product is not available in ${dashboard.selectedStoreName.value}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final item = CartItemEntity(
        barcode: product.barcode,
        name: product.name,
        subtitle: product.description ?? '',
        price: product.price,
        stock: product.stock,
      );

      Get.find<CartController>().addItem(item);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not look up product. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      isScanningPaused.value = false;
    }
  }
}
