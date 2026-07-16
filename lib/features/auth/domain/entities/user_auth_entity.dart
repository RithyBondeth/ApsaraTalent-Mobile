import '../enums/auth_login_method.dart';
import '../enums/user_role.dart';

class UserAuthEntity {
  final String id;
  final String phone;
  final UserRole role;
  final DateTime? lastLoginAt;
  final AuthLoginMethod lastLoginMethod;

  UserAuthEntity({
    required this.id,
    required this.phone,
    required this.role,
    this.lastLoginAt,
    required this.lastLoginMethod,
  });
}
