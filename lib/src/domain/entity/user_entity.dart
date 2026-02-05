class UserEntity {
  final String id;
  final String email;
  final String? password;

  const UserEntity({
    required this.id,
    required this.email,
    this.password,
  });
}
