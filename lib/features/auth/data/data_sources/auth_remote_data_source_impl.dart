import 'package:apsaratalent_mobile/core/constants/apis/auth_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_interceptors.dart';
import 'package:apsaratalent_mobile/core/session/auth_cookies.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/current_user_response.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/registration_request.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/two_factor_setup.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  /// Credential exchanges don't carry the session, and a 401 from one means
  /// "wrong password" or "wrong code" — never "refresh and retry".
  static final _public = Options(extra: SessionInterceptor.publicRequest);

  /// Signed-in requests to endpoints that also answer 401 for a wrong code.
  static final _business = Options(
    extra: SessionInterceptor.businessRejections,
  );

  @override
  Future<AuthDataSourceResult> login(String identifier, String password) async {
    final response = await _client.post(
      apiAuthLogin,
      data: {'identifier': identifier, 'password': password},
      options: _public,
    );
    final body = _loginBody(response);

    // The tokens come back as Set-Cookie headers, never in the body. A
    // two-factor step issues none until the second factor is verified.
    return AuthDataSourceResult(
      response: body,
      tokens: body.requiresTwoFactor ? null : AuthCookies.read(response.headers),
    );
  }

  @override
  Future<AuthDataSourceResult> verifyTwoFactor(
    String twoFactorToken,
    String otp,
  ) =>
      _exchange(apiAuthTwoFactorVerifyLogin, {
        'twoFactorToken': twoFactorToken,
        'otp': otp,
      });

  @override
  Future<String> requestPhoneOtp(String phone) =>
      _message(apiAuthLoginOtp, {'phone': phone});

  @override
  Future<AuthDataSourceResult> verifyPhoneOtp(String phone, String otp) =>
      _exchange(apiAuthVerifyOtp, {'phone': phone, 'otp': otp});

  @override
  Future<AuthDataSourceResult> registerEmployee(EmployeeRegistration request) =>
      _exchange(apiAuthRegisterEmployee, request.toJson());

  @override
  Future<AuthDataSourceResult> registerCompany(CompanyRegistration request) =>
      _exchange(apiAuthRegisterCompany, request.toJson());

  @override
  Future<String> verifyEmail(String email, String otp) =>
      _message(apiAuthVerifyEmail, {'email': email, 'otp': otp});

  @override
  Future<String> resendEmailOtp(String email) =>
      _message(apiAuthResendEmailOtp, {'email': email});

  @override
  Future<String> forgotPassword(String identifier) =>
      _message(apiAuthForgotPassword, {'identifier': identifier});

  @override
  Future<String> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) =>
      _message(apiAuthResetPassword(token), {
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });

  @override
  Future<TwoFactorSetup> setupTwoFactor() async {
    final response = await _client.post(apiAuthTwoFactorSetup);
    return TwoFactorSetup.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<String> enableTwoFactor(String otp) async {
    final response = await _client.post(
      apiAuthTwoFactorEnable,
      data: {'otp': otp},
      options: _business,
    );
    return _messageOf(response);
  }

  @override
  Future<String> disableTwoFactor(String otp) async {
    final response = await _client.post(
      apiAuthTwoFactorDisable,
      data: {'otp': otp},
      options: _business,
    );
    return _messageOf(response);
  }

  @override
  Future<void> logout() async {
    await _client.post(apiAuthLogout);
  }

  @override
  Future<CurrentUserResponse> fetchCurrentUser() async {
    final response = await _client.get(apiCurrentUser);
    return CurrentUserResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// A public request that issues a session in Set-Cookie.
  Future<AuthDataSourceResult> _exchange(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(path, data: body, options: _public);
    return AuthDataSourceResult(
      response: _loginBody(response),
      tokens: AuthCookies.read(response.headers),
    );
  }

  /// A public request whose only result is a message for the user.
  Future<String> _message(String path, Map<String, dynamic> body) async {
    final response = await _client.post(path, data: body, options: _public);
    return _messageOf(response);
  }

  static LoginResponse _loginBody(Response<dynamic> response) =>
      LoginResponse.fromJson(response.data as Map<String, dynamic>);

  static String _messageOf(Response<dynamic> response) =>
      ApiClient.messageFrom(response.data) ?? '';
}
