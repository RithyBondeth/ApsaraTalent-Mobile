// Implementation of auth repository
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/auth_tokens.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/current_user_entity.dart';
import 'package:apsaratalent_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SessionStore sessionStore,
  })  : _remoteDataSource = remoteDataSource,
        _sessionStore = sessionStore;

  final AuthRemoteDataSource _remoteDataSource;
  final SessionStore _sessionStore;

  @override
  Future<LoginResponse> login(
    String identifier,
    String password, {
    required bool remember,
  }) {
    return _guard('Login failed. Please try again.', () async {
      final result = await _remoteDataSource.login(identifier, password);
      if (!result.response.requiresTwoFactor) {
        await _keep(result.tokens, remember: remember);
      }
      return result.response;
    });
  }

  @override
  Future<LoginResponse> verifyTwoFactor(
    String twoFactorToken,
    String otp, {
    required bool remember,
  }) {
    return _guard('Verification failed. Please try again.', () async {
      final result = await _remoteDataSource.verifyTwoFactor(
        twoFactorToken,
        otp,
      );
      await _keep(result.tokens, remember: remember);
      return result.response;
    });
  }

  @override
  Future<bool> restoreSession() async =>
      await _sessionStore.restore() != null;

  @override
  Future<void> logout() async {
    try {
      // The API only clears its cookies here; it holds no server-side session
      // to revoke. The local wipe below is what actually signs the user out,
      // so a failed request must not stop it.
      if (_sessionStore.hasSession) await _remoteDataSource.logout();
    } catch (_) {
      // Offline or already expired — neither should keep anyone signed in.
    } finally {
      await _sessionStore.clear();
    }
  }

  @override
  Future<CurrentUserEntity> getCurrentUser() {
    return _guard('Could not load your account.', () async {
      final response = await _remoteDataSource.fetchCurrentUser();
      return response.toEntity();
    });
  }

  /// A success with no tokens would leave the user "signed in" with nothing to
  /// sign requests with — every call after it would 401. Fail it here instead.
  Future<void> _keep(AuthTokens? tokens, {required bool remember}) async {
    if (tokens == null) {
      throw ApiException(
        message: 'Sign-in succeeded but no session was issued. '
            'Please try again.',
      );
    }
    await _sessionStore.save(tokens, remember: remember);
  }

  Future<T> _guard<T>(String fallback, Future<T> Function() body) async {
    try {
      return await body();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: fallback);
    }
  }
}
