// Abstract interface for auth repository
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/current_user_entity.dart';

abstract class AuthRepository {
  /// Password sign-in. On success the session is stored — in the Keychain when
  /// [remember] is set, in memory otherwise. A response with
  /// `requiresTwoFactor` stores nothing yet.
  Future<LoginResponse> login(
    String identifier,
    String password, {
    required bool remember,
  });

  /// Exchanges a two-factor token and authenticator code for a session.
  Future<LoginResponse> verifyTwoFactor(
    String twoFactorToken,
    String otp, {
    required bool remember,
  });

  /// A remembered session from a previous launch, if there is one.
  Future<bool> restoreSession();

  /// Ends the session locally, and tells the API on a best-effort basis.
  Future<void> logout();

  Future<CurrentUserEntity> getCurrentUser();
}
