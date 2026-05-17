import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:dq_app/src/domain/repo/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;
  SignupUseCase({required this.repository});

  Future<AuthEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) {
    return repository.signUpWithEmail(name: name, email: email, password: password);
  }

  Future<AuthEntity> signInWithGoogle() {
    return repository.signInWithGoogle();
  }
}
