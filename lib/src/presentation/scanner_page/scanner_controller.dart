import 'package:dq_app/src/domain/usecase/get_product_by_barcode_usecase.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/presentation/scanner_page/widgets/product_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScannerController extends GetxController {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;

  ScannerController({required this.getProductByBarcodeUseCase});

  /// true while scanner should not process new barcodes
  final RxBool isScanningPaused = false.obs;

  /// 'loading' | 'error' | '' — shown in feedback card on scanner
  final RxString scanFeedback = ''.obs;
  final RxString scanFeedbackMessage = ''.obs;

  Future<void> onBarcodeDetected(String barcode) async {
    if (isScanningPaused.value) return;
    isScanningPaused.value = true;

    try {
      final dashboard = Get.find<DashboardController>();
      final storeId = dashboard.selectedStoreId.value;

      if (storeId.isEmpty) {
        await _showErrorFeedback('Please select a store before scanning');
        return;
      }

      // Show loading indicator while fetching from backend
      scanFeedback.value = 'loading';

      final product =
          await getProductByBarcodeUseCase.execute(barcode, storeId);

      if (product == null) {
        await _showErrorFeedback(
            'Not available in ${dashboard.selectedStoreName.value}');
        return;
      }

      // Clear loading, open product detail modal
      // Scanner stays paused until the sheet is dismissed
      scanFeedback.value = '';

      await Get.bottomSheet(
        ProductDetailSheet(product: product),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        enterBottomSheetDuration: const Duration(milliseconds: 350),
        exitBottomSheetDuration: const Duration(milliseconds: 250),
      );

      // Sheet closed — scanner resumes via finally block
    } catch (e) {
      await _showErrorFeedback(
          'Could not look up product. Check your connection.');
    } finally {
      isScanningPaused.value = false;
      scanFeedback.value = '';
      scanFeedbackMessage.value = '';
    }
  }

  Future<void> _showErrorFeedback(String message) async {
    scanFeedback.value = 'error';
    scanFeedbackMessage.value = message;
    await Future.delayed(const Duration(seconds: 2));
  }
}
