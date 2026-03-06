import 'package:dq_app/src/data/model/product_model.dart';
import 'package:dq_app/src/service_core/networks/graphql_service.dart';

class ProductRemoteDataSource {
  Future<ProductModel?> getProductByBarcode(
      String barcode, String storeId) async {
    const query = '''
      query GetProduct(\$barcode: String!, \$storeId: ID!) {
        productByBarcode(barcode: \$barcode, storeId: \$storeId) {
          id
          barcode
          name
          description
          price
          imageUrl
          stock
        }
      }
    ''';

    final result = await GraphQLService.performQuery(
      query: query,
      variables: {'barcode': barcode, 'storeId': storeId},
    );

    final data = result.data?['productByBarcode'];
    if (data == null) return null;
    return ProductModel.fromJson(data);
  }
}
