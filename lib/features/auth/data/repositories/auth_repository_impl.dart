import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source_impl.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/login_request.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/auth_entity.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/message_entity.dart';
import 'package:apsaratalent_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl();

  @override
  Future<AuthEntity> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _remoteDataSource.login(request);
      return AuthEntity(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user.toEntity(),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Login failed. Please try again.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Logout failed.');
    }
  }

  @override
  Future<MessageEntity> forgotPassword(String email) async {
    try {
      final response = await _remoteDataSource.forgotPassword(email);
      return MessageEntity(message: response.message);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to send reset email.');
    }
  }

  @override
  Future<MessageEntity> resetPassword(String token, String password) async {
    try {
      final response = await _remoteDataSource.resetPassword(token, password);
      return MessageEntity(message: response.message);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to reset password.');
    }
  }
}
