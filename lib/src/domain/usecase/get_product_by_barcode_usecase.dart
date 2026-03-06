import 'package:dq_app/src/domain/entity/product_entity.dart';
import 'package:dq_app/src/domain/repo/product_repository.dart';

class GetProductByBarcodeUseCase {
  final ProductRepository repository;

  GetProductByBarcodeUseCase({required this.repository});

  Future<ProductEntity?> execute(String barcode, String storeId) =>
      repository.getProductByBarcode(barcode, storeId);
}
