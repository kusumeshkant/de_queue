import 'package:dq_app/src/data/model/store_model.dart';
import 'package:dq_app/src/service_core/networks/graphql_service.dart';

class StoreRemoteDataSource {
  static const _storeFields = '''
    id storeCode name address imageUrl latitude longitude distanceKm
  ''';

  // Admin-only query — never call from customer-role context.
  Future<List<StoreModel>> getStores() async {
    final result = await GraphQLService.performQuery(query: '''
      query { stores { $_storeFields } }
    ''');
    final List<dynamic> data = result.data?['stores'] ?? [];
    return data.map((s) => StoreModel.fromJson(s)).toList();
  }

  // Public: returns stores within 2km radius sorted by distance.
  Future<List<StoreModel>> getNearbyStores(double lat, double lon) async {
    final result = await GraphQLService.performQuery(
      query: '''
        query NearbyStores(\$lat: Float!, \$lon: Float!) {
          nearbyStores(lat: \$lat, lon: \$lon) { $_storeFields }
        }
      ''',
      variables: {'lat': lat, 'lon': lon},
    );
    final List<dynamic> data = result.data?['nearbyStores'] ?? [];
    return data.map((s) => StoreModel.fromJson(s)).toList();
  }

  // Public: look up a single store by its store code.
  // Used for manual code entry and QR scan in the customer app.
  Future<StoreModel?> getStoreByCode(String code) async {
    final result = await GraphQLService.performQuery(
      query: '''
        query GetStoreByCode(\$code: String!) {
          getStoreByCode(code: \$code) { $_storeFields }
        }
      ''',
      variables: {'code': code.trim().toUpperCase()},
    );
    final data = result.data?['getStoreByCode'];
    if (data == null) return null;
    return StoreModel.fromJson(data as Map<String, dynamic>);
  }
}
