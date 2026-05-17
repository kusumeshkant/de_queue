import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:dq_app/src/domain/entity/auth_exception.dart';
import 'package:dq_app/core/observability/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // GoogleSignIn uses native platform plugins unavailable on web.
  // Web sign-in goes through signInWithPopup instead.
  final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();

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
      AppLogger.logTokenRetrieval(
        success: token != null,
        truncatedToken: token,
      );
      return AuthEntity(token: token ?? '', isLoggedIn: true);
    } on FirebaseAuthException catch (e) {
      AppLogger.logTokenRetrieval(success: false, error: e.code);
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
      AppLogger.logTokenRetrieval(
        success: token != null,
        truncatedToken: token,
      );
      return AuthEntity(token: token ?? '', isLoggedIn: true);
    } on FirebaseAuthException catch (e) {
      AppLogger.logTokenRetrieval(success: false, error: e.code);
      throw Exception(_mapError(e.code));
    }
  }

  Future<AuthEntity> signInWithGoogle() async {
    if (kIsWeb) return _signInWithGoogleWeb();
    return _signInWithGoogleNative();
  }

  /// Web: Firebase popup with automatic redirect fallback.
  ///
  /// Popup is tried first. If it fails for any network/environment reason
  /// (timeout, popup blocked, ERR_CONNECTION_TIMED_OUT), we fall back to
  /// [signInWithRedirect]. The redirect result is captured at next app
  /// startup via [getRedirectResult] in main.dart.
  Future<AuthEntity> _signInWithGoogleWeb() async {
    AppLogger.logGoogleSignIn('started', detail: 'web-popup');

    // Pre-popup diagnostics — visible in browser DevTools Console.
    final opts = Firebase.app().options;
    // ignore: avoid_print
    print('[DQ-AUTH] window.origin=${Uri.base.origin}');
    // ignore: avoid_print
    print('[DQ-AUTH] firebase.projectId=${opts.projectId}');
    // ignore: avoid_print
    print('[DQ-AUTH] firebase.authDomain=${opts.authDomain}');
    // ignore: avoid_print
    print('[DQ-AUTH] firebase.appId=${opts.appId}');
    // ignore: avoid_print
    print('[DQ-AUTH] currentUser=${_auth.currentUser?.uid ?? 'none'}');

    final provider = GoogleAuthProvider();
    // ignore: avoid_print
    print('[DQ-AUTH] provider=${provider.providerId} — calling signInWithPopup');

    try {
      final userCredential = await _auth.signInWithPopup(provider);
      AppLogger.logGoogleSignIn('firebase_ok', detail: 'uid=${userCredential.user?.uid}');
      final token = await userCredential.user?.getIdToken();
      AppLogger.logTokenRetrieval(success: token != null, truncatedToken: token);
      return AuthEntity(token: token ?? '', isLoggedIn: true);
    } on FirebaseAuthException catch (e) {
      AppLogger.logGoogleSignIn('failed', detail: 'firebase=${e.code}');
      // User explicitly dismissed the popup — do not redirect.
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
        throw Exception('Google sign-in cancelled');
      }
      // All other Firebase errors (network-request-failed, popup-blocked,
      // web-storage-unsupported, etc.) fall back to redirect.
      // ignore: avoid_print
      print('[DQ-AUTH] popup error (${e.code}), falling back to redirect');
      return _signInWithGoogleRedirect(provider);
    } catch (e) {
      // Unknown / network-level errors (ERR_CONNECTION_TIMED_OUT, etc.).
      AppLogger.logGoogleSignIn('failed', detail: e.toString());
      // ignore: avoid_print
      print('[DQ-AUTH] popup threw ($e), falling back to redirect');
      return _signInWithGoogleRedirect(provider);
    }
  }

  /// Initiates a full-page redirect OAuth flow.
  ///
  /// The browser navigates away immediately. Auth result is captured at next
  /// startup via [FirebaseAuth.getRedirectResult] in main.dart.
  /// Throws [GoogleSignInRedirectStarted] so callers keep their loading state.
  Future<AuthEntity> _signInWithGoogleRedirect(GoogleAuthProvider provider) async {
    AppLogger.logGoogleSignIn('redirect_started');
    // ignore: avoid_print
    print('[DQ-AUTH] starting signInWithRedirect...');
    await _auth.signInWithRedirect(provider);
    // Browser navigates away. Code below is unreachable in practice.
    // The sentinel is thrown to signal callers not to treat this as an error.
    throw const GoogleSignInRedirectStarted();
  }

  /// Android / iOS: native GoogleSignIn package flow.
  Future<AuthEntity> _signInWithGoogleNative() async {
    AppLogger.logGoogleSignIn('started');
    try {
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        AppLogger.logGoogleSignIn('cancelled');
        throw Exception('Google sign-in cancelled');
      }

      AppLogger.logGoogleSignIn('token_ok', detail: 'email=${googleUser.email}');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      AppLogger.logGoogleSignIn('firebase_ok', detail: 'uid=${result.user?.uid}');

      final token = await result.user?.getIdToken();
      AppLogger.logTokenRetrieval(success: token != null, truncatedToken: token);

      return AuthEntity(token: token ?? '', isLoggedIn: true);
    } on PlatformException catch (e) {
      // code 10 = DEVELOPER_ERROR: SHA-1 not registered in Firebase for this
      // package. Fix: add the debug keystore SHA-1 to Firebase Console.
      final detail = 'code=${e.code} message=${e.message}';
      AppLogger.logGoogleSignIn('failed', detail: detail);
      if (e.code == 'sign_in_failed' && (e.message?.contains('10') ?? false)) {
        throw Exception(
          'Google Sign-In configuration error (DEVELOPER_ERROR). '
          'The app signing certificate SHA-1 is not registered in Firebase '
          'for this build variant. Contact the developer.',
        );
      }
      throw Exception('Google Sign-In failed: ${e.message}');
    } on FirebaseAuthException catch (e) {
      AppLogger.logGoogleSignIn('failed', detail: 'firebase=${e.code}');
      throw Exception(_mapError(e.code));
    } catch (e) {
      AppLogger.logGoogleSignIn('failed', detail: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _googleSignIn?.signOut();
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
