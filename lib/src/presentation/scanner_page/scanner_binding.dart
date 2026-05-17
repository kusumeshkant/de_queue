import 'package:dq_app/src/data/datasources/remote/product_remote_ds.dart';
import 'package:dq_app/src/data/repo_impl/product_repository_impl.dart';
import 'package:dq_app/src/domain/repo/product_repository.dart';
import 'package:dq_app/src/domain/usecase/get_product_by_barcode_usecase.dart';
import 'package:dq_app/src/presentation/scanner_page/scanner_controller.dart';
import 'package:get/get.dart';

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductRemoteDataSource());
    Get.lazyPut<ProductRepository>(
        () => ProductRepositoryImpl(remote: Get.find()));
    Get.lazyPut(
        () => GetProductByBarcodeUseCase(repository: Get.find()));
    Get.lazyPut(() => ScannerController(
        getProductByBarcodeUseCase: Get.find()));
  }
}
