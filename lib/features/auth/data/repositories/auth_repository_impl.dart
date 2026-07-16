import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source_impl.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/login_entity.dart';
import 'package:apsaratalent_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl();

  @override
  Future<dynamic> login(String email, String password) async {
    try {
      final result = await _remoteDataSource.login(email, password);
      final response = result.response;

      if (response.requiresTwoFactor == true) {
        return LoginTwoFactorEntity(
          message: response.message,
          userId: response.userId ?? '',
        );
      }

      if (response.user == null) {
        throw ApiException(message: 'Invalid response from server');
      }

      return LoginSuccessEntity(
        message: response.message,
        user: response.user!.toEntity(),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Login failed. Please try again.');
    }
  }
}
