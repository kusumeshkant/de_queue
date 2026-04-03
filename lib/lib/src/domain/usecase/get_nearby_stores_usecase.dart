import '../entity/store_entity.dart';
import '../repo/store_repository.dart';

class GetNearbyStoresUseCase {
  final StoreRepository repository;
  const GetNearbyStoresUseCase({required this.repository});

  Future<List<StoreEntity>> execute(double lat, double lon) =>
      repository.getNearbyStores(lat, lon);
}
