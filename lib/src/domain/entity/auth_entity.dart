class AuthEntity {
  final String token;
  final bool isLoggedIn;

  const AuthEntity({
    required this.token,
    required this.isLoggedIn,
  });
}
