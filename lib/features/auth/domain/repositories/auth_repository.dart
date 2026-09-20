// Abstract interface for auth repository
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/registration_request.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/two_factor_setup.dart';
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

  Future<String> requestPhoneOtp(String phone);

  /// Signs in with a phone number and its code, storing the session.
  Future<LoginResponse> verifyPhoneOtp(
    String phone,
    String otp, {
    required bool remember,
  });

  /// Creates the account and stores the session it issues. A new account is
  /// always remembered: losing it on the next launch, before the user has even
  /// verified their email, would strand them.
  Future<LoginResponse> registerEmployee(EmployeeRegistration request);
  Future<LoginResponse> registerCompany(CompanyRegistration request);

  Future<String> verifyEmail(String email, String otp);
  Future<String> resendEmailOtp(String email);

  Future<String> forgotPassword(String identifier);
  Future<String> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  Future<TwoFactorSetup> setupTwoFactor();
  Future<String> enableTwoFactor(String otp);
  Future<String> disableTwoFactor(String otp);

  /// A remembered session from a previous launch, if there is one.
  Future<bool> restoreSession();

  /// Ends the session locally, and tells the API on a best-effort basis.
  Future<void> logout();

  Future<CurrentUserEntity> getCurrentUser();
}
