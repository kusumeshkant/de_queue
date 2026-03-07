import 'package:dq_app/src/data/datasources/remote/profile_remote_ds.dart';
import 'package:dq_app/src/domain/entity/user_entity.dart';
import 'package:dq_app/src/domain/repo/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl({required this.remote});

  @override
  Future<UserEntity> getProfile() => remote.getProfile();

  @override
  Future<UserEntity> updateProfile({String? name, String? email}) =>
      remote.updateProfile(name: name, email: email);
}
