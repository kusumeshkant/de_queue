import 'package:dq_app/src/domain/entity/store_entity.dart';

abstract class StoreRepository {
  Future<List<StoreEntity>> getStores();
  Future<List<StoreEntity>> getNearbyStores(double lat, double lon);
}
