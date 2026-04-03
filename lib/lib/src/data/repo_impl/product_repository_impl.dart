import 'package:dq_app/src/data/datasources/remote/product_remote_ds.dart';
import 'package:dq_app/src/domain/entity/product_entity.dart';
import 'package:dq_app/src/domain/repo/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;

  ProductRepositoryImpl({required this.remote});

  @override
  Future<ProductEntity?> getProductByBarcode(String barcode, String storeId) =>
      remote.getProductByBarcode(barcode, storeId);
}
