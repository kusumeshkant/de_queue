

import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:dq_app/src/domain/repo/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthEntity> call(
    String email,
    String password,
  ) {
    return repository.login(email, password);
  }
}
