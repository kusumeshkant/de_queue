import 'package:dq_app/src/domain/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.phone,
    super.name,
    super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        phone: json['phone'] as String?,
        name: json['name'] as String?,
        email: json['email'] as String?,
      );
}
