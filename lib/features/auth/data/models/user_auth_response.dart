import 'package:apsaratalent_mobile/features/auth/domain/enums/auth_login_method_enum.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/user_auth_entity.dart';

class UserAuthResponse {
  final String id;
  final String phone;
  final String role;
  final String? lastLoginAt;
  final String lastLoginMethod;

  UserAuthResponse({
    required this.id,
    required this.phone,
    required this.role,
    this.lastLoginAt,
    required this.lastLoginMethod,
  });

  factory UserAuthResponse.fromJson(Map<String, dynamic> json) {
    return UserAuthResponse(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'none',
      lastLoginAt: json['lastLoginAt'],
      lastLoginMethod: json['lastLoginMethod'] ?? 'email_password',
    );
  }

  UserAuthEntity toEntity() {
    return UserAuthEntity(
      id: id,
      phone: phone,
      role: EUserRole.fromString(role),
      lastLoginAt: lastLoginAt != null ? DateTime.tryParse(lastLoginAt!) : null,
      lastLoginMethod: EAuthLoginMethod.fromString(lastLoginMethod),
    );
  }
}
