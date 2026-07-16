import 'user_auth_response.dart';

class LoginResponse {
  final String message;
  final UserAuthResponse? user;
  final bool? requiresTwoFactor;
  final String? userId;

  LoginResponse({
    required this.message,
    this.user,
    this.requiresTwoFactor,
    this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      user: json['user'] != null ? UserAuthResponse.fromJson(json['user']) : null,
      requiresTwoFactor: json['requiresTwoFactor'],
      userId: json['userId'],
    );
  }
}
