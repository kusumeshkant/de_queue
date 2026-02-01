
import 'package:dq_app/core/enums/data_source_type.dart';
import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:dq_app/src/domain/repo/auth_repository.dart';

import '../datasources/local/auth_local_ds.dart';
import '../datasources/remote/auth_remote_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource local;
  final AuthRemoteDataSource remote;
  final DataSourceType source;

  AuthRepositoryImpl({
    required this.local,
    required this.remote,
    required this.source,
  });

  @override
  Future<AuthEntity> login(
    String email,
    String password,
  ) async {
    if (source == DataSourceType.local) {
      final auth = local.get();
      if (auth == null) {
        throw Exception('No local auth found');
      }
      return auth;
    } else {
      final auth = await remote.login(email, password);
      await local.save(auth); // cache
      return auth;
    }
  }
}
