import 'package:apsaratalent_mobile/features/auth/domain/enums/auth_login_method_enum.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/login_entity.dart';

// User data from API response
class UserAuthResponse {
  final String id; // User ID
  final String phone; // User phone number
  final String role; // User role as string ("employee")
  final String? lastLoginAt; // Last login as ISO string
  final String lastLoginMethod; // Login method as string ("email_password")

  UserAuthResponse({
    required this.id,
    required this.phone,
    required this.role,
    this.lastLoginAt,
    required this.lastLoginMethod,
  });

  // Parse from API JSON response
  factory UserAuthResponse.fromJson(Map<String, dynamic> json) {
    return UserAuthResponse(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'none',
      lastLoginAt: json['lastLoginAt'],
      lastLoginMethod: json['lastLoginMethod'] ?? 'email_password',
    );
  }

  // Convert to domain entity
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

// Login response from API
class LoginResponse {
  final String message; // Response message
  final UserAuthResponse? user; // User data (null if 2FA required)
  final bool? requiresTwoFactor; // true if 2FA needed
  final String? userId; // User ID (only when 2FA required)

  LoginResponse({
    required this.message,
    this.user,
    this.requiresTwoFactor,
    this.userId,
  });

  // Parse from API JSON response
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      user:
          json['user'] != null ? UserAuthResponse.fromJson(json['user']) : null,
      requiresTwoFactor: json['requiresTwoFactor'],
      userId: json['userId'],
    );
  }
}

// Result from data source (response + tokens from headers)
class LoginDataSourceResult {
  final LoginResponse response; // Parsed response body
  final String? accessToken; // Token from Authorization header
  final String? refreshToken; // Token from x-refresh-token header

  LoginDataSourceResult({
    required this.response,
    this.accessToken,
    this.refreshToken,
  });
}
