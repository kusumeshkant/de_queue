import 'package:dq_app/src/domain/entity/auth_entity.dart';

abstract class AuthRepository {
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onFailed,
  });

  Future<AuthEntity> verifyOtp({
    required String verificationId,
    required String otp,
  });

  Future<void> logout();
}
