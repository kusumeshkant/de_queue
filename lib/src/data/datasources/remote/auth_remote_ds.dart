import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (_) {},
      verificationFailed: (e) => onFailed(_mapFirebaseError(e.code)),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<AuthEntity> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final result = await _auth.signInWithCredential(credential);
      final token = await result.user?.getIdToken();
      return AuthEntity(token: token ?? '', isLoggedIn: true);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-verification-code':
        return 'Invalid OTP. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
