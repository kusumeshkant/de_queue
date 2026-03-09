import 'package:dq_app/src/data/datasources/local/auth_local_ds.dart';
import 'package:dq_app/src/data/datasources/remote/auth_remote_ds.dart';
import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:dq_app/src/domain/repo/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource local;
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl({
    required this.local,
    required this.remote,
  });

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onFailed,
  }) {
    return remote.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onFailed: onFailed,
    );
  }

  @override
  Future<AuthEntity> verifyOtp({
    required String verificationId,
    required String otp,
    bool isSignUp = false,
  }) async {
    final auth = await remote.verifyOtp(
      verificationId: verificationId,
      otp: otp,
      isSignUp: isSignUp,
    );
    await local.save(auth);
    return auth;
  }

  @override
  Future<void> logout() async {
    await remote.logout();
    await local.clear();
  }
}
