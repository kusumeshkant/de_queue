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
}
