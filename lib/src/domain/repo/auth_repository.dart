import 'package:dq_app/src/domain/entity/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthEntity> signInWithGoogle();

  Future<void> logout();
}
