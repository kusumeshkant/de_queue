import 'package:dq_app/src/domain/entity/cart_item_entity.dart';
import 'package:dq_app/src/domain/usecase/get_product_by_barcode_usecase.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:get/get.dart';

class ScannerController extends GetxController {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;

  ScannerController({required this.getProductByBarcodeUseCase});

  final RxBool isScanningPaused = false.obs;

  final RxString scanFeedback = ''.obs; // 'success', 'error', or ''
  final RxString scanFeedbackName = ''.obs;
  final RxDouble scanFeedbackPrice = 0.0.obs;
  final RxString scanFeedbackMessage = ''.obs;

  Future<void> onBarcodeDetected(String barcode) async {
    if (isScanningPaused.value) return;
    isScanningPaused.value = true;

    try {
      final dashboard = Get.find<DashboardController>();
      final storeId = dashboard.selectedStoreId.value;

      // ── Negative: no store selected ───────────────────────────────────
      if (storeId.isEmpty) {
        scanFeedback.value = 'error';
        scanFeedbackMessage.value = 'Please select a store before scanning';
        return;
      }

      final product =
          await getProductByBarcodeUseCase.execute(barcode, storeId);

      // ── Negative: product not in this store ───────────────────────────
      if (product == null) {
        scanFeedback.value = 'error';
        scanFeedbackMessage.value =
            'Not available in ${dashboard.selectedStoreName.value}';
        return;
      }

      final item = CartItemEntity(
        barcode: product.barcode,
        name: product.name,
        subtitle: product.description ?? '',
        sku: product.sku,
        price: product.price,
        stock: product.stock,
      );

      final added = Get.find<CartController>().addItem(item);

      // ── Negative: stock limit reached ─────────────────────────────────
      if (!added) {
        scanFeedback.value = 'error';
        scanFeedbackMessage.value =
            '${product.name} is at stock limit (${product.stock} max)';
        return;
      }

      // ── Success ───────────────────────────────────────────────────────
      scanFeedback.value = 'success';
      scanFeedbackName.value = product.name;
      scanFeedbackPrice.value = product.price;
    } catch (e) {
      // ── Negative: network / unexpected error ──────────────────────────
      scanFeedback.value = 'error';
      scanFeedbackMessage.value = 'Could not look up product. Check your connection.';
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      isScanningPaused.value = false;
      scanFeedback.value = '';
    }
  }
}
