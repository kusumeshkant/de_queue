import 'package:dq_app/src/data/datasources/local/auth_local_ds.dart';
import 'package:dq_app/src/data/datasources/remote/auth_remote_ds.dart';
import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:dq_app/src/domain/repo/auth_repository.dart';
import 'package:dq_app/src/service_core/networks/graphql_client_provider.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource local;
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl({required this.local, required this.remote});

  @override
  Future<AuthEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = await remote.signInWithEmail(email: email, password: password);
    await local.save(auth);
    return auth;
  }

  @override
  Future<AuthEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final auth = await remote.signUpWithEmail(name: name, email: email, password: password);
    await local.save(auth);
    return auth;
  }

  @override
  Future<AuthEntity> signInWithGoogle() async {
    final auth = await remote.signInWithGoogle();
    await local.save(auth);
    return auth;
  }

  @override
  Future<void> logout() async {
    // Drop the GraphQL client before Firebase signOut so that any in-flight
    // requests cannot use a stale client after the session ends.
    GraphQLClientProvider.reset();
    await remote.logout();
    await local.clear();
  }
}
