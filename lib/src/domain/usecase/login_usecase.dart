import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:dq_app/src/domain/repo/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onFailed,
  }) {
    return repository.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onFailed: onFailed,
    );
  }

  Future<AuthEntity> verifyOtp({
    required String verificationId,
    required String otp,
  }) {
    return repository.verifyOtp(
      verificationId: verificationId,
      otp: otp,
    );
  }
}
