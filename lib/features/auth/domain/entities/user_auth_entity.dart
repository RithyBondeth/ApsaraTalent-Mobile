// Domain entity for user data
import '../enums/auth_login_method_enum.dart';
import '../enums/user_role_enum.dart';

// User data your app cares about
class UserAuthEntity {
  final String id; // User ID
  final String phone; // User phone number
  final EUserRole role; // User role (employee, company, admin)
  final DateTime? lastLoginAt; // Last login timestamp
  final EAuthLoginMethod lastLoginMethod; // How user logged in

  UserAuthEntity({
    required this.id,
    required this.phone,
    required this.role,
    this.lastLoginAt,
    required this.lastLoginMethod,
  });
}
