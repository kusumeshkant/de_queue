import 'package:dq_app/src/data/datasources/remote/store_remote_ds.dart';
import 'package:dq_app/src/domain/entity/store_entity.dart';
import 'package:dq_app/src/domain/repo/store_repository.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remote;

  StoreRepositoryImpl({required this.remote});

  @override
  Future<List<StoreEntity>> getStores() => remote.getStores();

  @override
  Future<List<StoreEntity>> getNearbyStores(double lat, double lon) =>
      remote.getNearbyStores(lat, lon);
}
