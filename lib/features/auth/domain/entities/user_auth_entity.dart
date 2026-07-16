import '../enums/auth_login_method_enum.dart';
import '../enums/user_role_enum.dart';

class UserAuthEntity {
  final String id;
  final String phone;
  final EUserRole role;
  final DateTime? lastLoginAt;
  final EAuthLoginMethod lastLoginMethod;

  UserAuthEntity({
    required this.id,
    required this.phone,
    required this.role,
    this.lastLoginAt,
    required this.lastLoginMethod,
  });
}
