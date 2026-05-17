import 'package:dq_app/src/data/model/store_model.dart';
import 'package:dq_app/src/service_core/networks/graphql_service.dart';

class StoreRemoteDataSource {
  static const _storeFields = '''
    id storeCode name address imageUrl latitude longitude distanceKm
  ''';

  Future<List<StoreModel>> getStores() async {
    final result = await GraphQLService.performQuery(query: '''
      query { stores { $_storeFields } }
    ''');
    final List<dynamic> data = result.data?['stores'] ?? [];
    return data.map((s) => StoreModel.fromJson(s)).toList();
  }

  // TODO(production): Replace with real nearbyStores query using lat/lon + 2km
  // radius filter. Currently returns all stores for demo — testers are not
  // physically located near the seeded Bengaluru stores.
  Future<List<StoreModel>> getNearbyStores(double lat, double lon) =>
      getStores();
}
