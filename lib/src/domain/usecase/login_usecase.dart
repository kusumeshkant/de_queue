import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:dq_app/src/domain/repo/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase({required this.repository});

  Future<AuthEntity> signInWithEmail({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmail(email: email, password: password);
  }

  Future<AuthEntity> signInWithGoogle() {
    return repository.signInWithGoogle();
  }
}
