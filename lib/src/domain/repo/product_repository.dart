import 'package:dq_app/src/domain/entity/product_entity.dart';

abstract class ProductRepository {
  Future<ProductEntity?> getProductByBarcode(String barcode, String storeId);
}
