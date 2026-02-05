

import 'package:dq_app/core/enums/data_source_type.dart';
import 'package:dq_app/src/data/datasources/local/auth_local_ds.dart';
import 'package:dq_app/src/data/datasources/remote/auth_remote_ds.dart';
import 'package:dq_app/src/data/repo_impl/auth_repository_impl.dart';
import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:dq_app/src/domain/repo/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository = AuthRepositoryImpl(
        local: AuthLocalDataSource() ,
        remote: AuthRemoteDataSource(),
        source: DataSourceType.local,
      );


  Future<AuthEntity> login(
    String email,
    String password,
  ) {
    return repository.login(email, password);
  }
}
