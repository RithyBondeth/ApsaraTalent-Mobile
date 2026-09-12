import 'package:apsaratalent_mobile/core/constants/apis/auth_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_interceptors.dart';
import 'package:apsaratalent_mobile/core/session/auth_cookies.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/current_user_response.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  /// Credential exchanges don't carry the session, and a 401 from one means
  /// "wrong password" — never "refresh and retry".
  static final _public = Options(extra: SessionInterceptor.publicRequest);

  @override
  Future<AuthDataSourceResult> login(String identifier, String password) async {
    final response = await _client.post(
      apiAuthLogin,
      data: {'identifier': identifier, 'password': password},
      options: _public,
    );
    final body = LoginResponse.fromJson(response.data as Map<String, dynamic>);

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
  ) async {
    final response = await _client.post(
      apiAuthTwoFactorVerifyLogin,
      data: {'twoFactorToken': twoFactorToken, 'otp': otp},
      options: _public,
    );
    return AuthDataSourceResult(
      response: LoginResponse.fromJson(response.data as Map<String, dynamic>),
      tokens: AuthCookies.read(response.headers),
    );
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
}
