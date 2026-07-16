import 'package:apsaratalent_mobile/features/auth/domain/enums/auth_login_method_enum.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';

// User data returned after successful login
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

// Login result when 2FA is required
class LoginTwoFactorEntity {
  final String message; // "Verification required"
  final String userId; // User ID for OTP screen

  LoginTwoFactorEntity({required this.message, required this.userId});
}

// Login result when login is successful
class LoginSuccessEntity {
  final String message; // "Login successful"
  final UserAuthEntity user; // User data

  LoginSuccessEntity({required this.message, required this.user});
}
