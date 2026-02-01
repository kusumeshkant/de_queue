import 'package:dq_app/src/domain/entity/auth_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthEntity> login(
    String email,
    String password,
  ) async {
    final user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final token = await user.user?.getIdToken();

    return AuthEntity(
      token: token ?? '',
      isLoggedIn: true,
    );
  }
}
