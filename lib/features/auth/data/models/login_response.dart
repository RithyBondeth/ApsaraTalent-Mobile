import 'package:apsaratalent_mobile/core/session/auth_tokens.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/auth_login_method_enum.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/user_auth_entity.dart';

// User data from API response
class UserAuthResponse {
  final String id; // User ID
  final String? email; // Null for a phone-only account
  final String? phone; // Null for an email-only account
  final String role; // User role as string ("employee")
  final String? lastLoginAt; // Last login as ISO string
  final String lastLoginMethod; // Login method as string ("email_password")

  UserAuthResponse({
    required this.id,
    this.email,
    this.phone,
    required this.role,
    this.lastLoginAt,
    required this.lastLoginMethod,
  });

  // Parse from API JSON response
  factory UserAuthResponse.fromJson(Map<String, dynamic> json) {
    return UserAuthResponse(
      id: json['id'] ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] ?? 'none',
      lastLoginAt: json['lastLoginAt'] as String?,
      lastLoginMethod: json['lastLoginMethod'] ?? 'email_password',
    );
  }

  // Convert to domain entity
  UserAuthEntity toEntity() {
    return UserAuthEntity(
      id: id,
      email: email,
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
  final bool requiresTwoFactor; // true if 2FA needed

  /// Short-lived proof that the password step passed. Only present when
  /// [requiresTwoFactor]; it is exchanged, with the authenticator code, for a
  /// session at `/auth/2fa/verify-login`.
  final String? twoFactorToken;

  LoginResponse({
    required this.message,
    this.user,
    required this.requiresTwoFactor,
    this.twoFactorToken,
  });

  // Parse from API JSON response
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      user:
          json['user'] != null ? UserAuthResponse.fromJson(json['user']) : null,
      requiresTwoFactor: json['requiresTwoFactor'] ?? false,
      twoFactorToken: json['twoFactorToken'] as String?,
    );
  }
}

/// A credential exchange's result: the parsed body plus the session it issued.
///
/// [tokens] is null when no session was issued — a password step that still
/// needs its second factor.
class AuthDataSourceResult {
  final LoginResponse response;
  final AuthTokens? tokens;

  AuthDataSourceResult({required this.response, this.tokens});
}
