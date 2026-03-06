import 'package:dq_app/src/domain/entity/user_entity.dart';
import 'package:dq_app/src/domain/repo/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase({required this.repository});

  Future<UserEntity> execute() => repository.getProfile();
}
