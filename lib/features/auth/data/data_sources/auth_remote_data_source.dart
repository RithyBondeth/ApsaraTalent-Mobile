import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';

class LoginDataSourceResult {
  final LoginResponse response;
  final String? accessToken;
  final String? refreshToken;

  LoginDataSourceResult({
    required this.response,
    this.accessToken,
    this.refreshToken,
  });
}

abstract class AuthRemoteDataSource {
  Future<LoginDataSourceResult> login(String email, String password);
}
