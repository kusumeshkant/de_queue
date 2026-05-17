import 'package:dq_app/src/domain/entity/store_entity.dart';
import 'package:dq_app/src/domain/repo/store_repository.dart';

class GetStoresUseCase {
  final StoreRepository repository;

  GetStoresUseCase({required this.repository});

  Future<List<StoreEntity>> execute() => repository.getStores();
}
