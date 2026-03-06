import 'package:dq_app/src/domain/entity/user_entity.dart';
import 'package:dq_app/src/domain/repo/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<UserEntity> execute({required String name}) =>
      repository.updateProfile(name: name);
}
