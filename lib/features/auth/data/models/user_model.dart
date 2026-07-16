import 'package:apsaratalent_mobile/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? avatar;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      phone: phone,
      avatar: avatar,
    );
  }
}
