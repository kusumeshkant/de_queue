class UserEntity {
  final String id;
  final String? phone;
  final String? name;
  final String? email;

  const UserEntity({
    required this.id,
    this.phone,
    this.name,
    this.email,
  });

  String get initials {
    if (name != null && name!.trim().isNotEmpty) {
      final parts = name!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name![0].toUpperCase();
    }
    if (phone != null && phone!.isNotEmpty) {
      return phone!.replaceAll('+91', '').substring(0, 2);
    }
    return 'U';
  }
}
