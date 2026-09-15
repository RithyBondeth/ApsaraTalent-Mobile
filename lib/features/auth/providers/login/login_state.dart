import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';

class LoginState {
  final LoginResponse? loginResponse;
  final bool isLoading;
  final String? error;

  /// Set when the API refused the sign-in because this email address was never
  /// verified. The screen routes to verification with it instead of showing an
  /// error the user can't act on.
  final String? unverifiedEmail;

  LoginState({
    this.loginResponse,
    this.isLoading = false,
    this.error,
    this.unverifiedEmail,
  });

  bool get requiresTwoFactor => loginResponse?.requiresTwoFactor ?? false;
  bool get isLoggedIn => loginResponse?.user != null;

  LoginState copyWith({
    LoginResponse? loginResponse,
    bool? isLoading,
    String? error,
    bool clearResponse = false,
    bool clearError = false,
  }) {
    return LoginState(
      loginResponse:
          clearResponse ? null : (loginResponse ?? this.loginResponse),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
