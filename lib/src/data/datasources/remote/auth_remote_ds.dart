import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<AuthEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final token = await result.user?.getIdToken();
      return AuthEntity(token: token ?? '', isLoggedIn: true);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e.code));
    }
  }

  Future<AuthEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.updateDisplayName(name);
      final token = await result.user?.getIdToken();
      return AuthEntity(token: token ?? '', isLoggedIn: true);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e.code));
    }
  }

  Future<AuthEntity> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final token = await result.user?.getIdToken();
      return AuthEntity(token: token ?? '', isLoggedIn: true);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e.code));
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
