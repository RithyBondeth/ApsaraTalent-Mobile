import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/message_response.dart';
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

  @override
  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  @override
  Future<MessageResponse> forgotPassword(String email) async {
    final response = await _client.post('/auth/forgot-password', data: {'email': email});
    return MessageResponse.fromJson(response.data);
  }

  @override
  Future<MessageResponse> resetPassword(String token, String password) async {
    final response = await _client.post('/auth/reset-password', data: {
      'token': token,
      'password': password,
    });
    return MessageResponse.fromJson(response.data);
  }
}
