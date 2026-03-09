import 'package:dq_app/src/domain/entity/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> getProfile();
  Future<UserEntity> updateProfile({required String name});
}
