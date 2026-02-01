import 'package:dq_app/src/domain/entity/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login(String email, String password);
  // AuthEntity? getLocalAuth();
}
