import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/entity/product_entity.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  final _quantity = 1.obs;
  final _isAdding = false.obs;

  int get quantity => _quantity.value;
  bool get isAdding => _isAdding.value;

  void increment(int maxStock) {
    if (maxStock <= 0 || _quantity.value < maxStock) {
      _quantity.value++;
      HapticFeedback.selectionClick();
    }
  }

  void decrement() {
    if (_quantity.value > 1) {
      _quantity.value--;
      HapticFeedback.selectionClick();
    }
  }

  /// Returns actual quantity added (0 if stock limit already reached).
  Future<int> addToCart(ProductEntity product) async {
    if (_isAdding.value) return 0;
    _isAdding.value = true;
    try {
      HapticFeedback.mediumImpact();
      final cart = Get.find<CartController>();
      final item = CartItemEntity(
        barcode: product.barcode,
        name: product.name,
        subtitle: product.description ?? '',
        sku: product.sku,
        mrp: product.mrp,
        price: product.price,
        stock: product.stock,
      );
      return cart.addItemWithQuantity(item, _quantity.value);
    } finally {
      _isAdding.value = false;
    }
  }
}
