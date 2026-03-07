import 'package:dq_app/src/domain/entity/user_entity.dart';
import 'package:dq_app/src/domain/repo/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<UserEntity> execute({String? name, String? email}) =>
      repository.updateProfile(name: name, email: email);
}
