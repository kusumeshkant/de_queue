import 'package:dq_app/src/domain/entity/store_entity.dart';
import 'package:dq_app/src/domain/repo/store_repository.dart';

class GetStoreByCodeUseCase {
  final StoreRepository repository;

  GetStoreByCodeUseCase({required this.repository});

  Future<StoreEntity?> execute(String code) => repository.getStoreByCode(code);
}
