import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl({ApiClient? client})
      : _client = client ?? ApiClient();

  @override
  Future<LoginDataSourceResult> login(String email, String password) async {
    // Make POST request to /auth/login
    final response = await _client.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    // Parse response body
    final loginResponse = LoginResponse.fromJson(response.data);

    // Extract tokens from headers
    final accessToken = response.headers['authorization']?.first;
    final refreshToken = response.headers['x-refresh-token']?.first;

    // Return combined result
    return LoginDataSourceResult(
      response: loginResponse,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
