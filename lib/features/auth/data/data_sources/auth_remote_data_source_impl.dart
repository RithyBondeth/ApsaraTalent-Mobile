import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl({ApiClient? client}) : _client = client ?? ApiClient();

  @override
  Future<LoginDataSourceResult> login(String email, String password) async {
    final response = await _client.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final loginResponse = LoginResponse.fromJson(response.data);
    final accessToken = response.headers['authorization']?.first;
    final refreshToken = response.headers['x-refresh-token']?.first;

    return LoginDataSourceResult(
      response: loginResponse,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
