import 'package:apsaratalent_mobile/features/auth/data/models/current_user_response.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/registration_request.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/two_factor_setup.dart';

abstract class AuthRemoteDataSource {
  /// Password sign-in. [identifier] is an email address or a phone number —
  /// the API's login DTO takes either under the one field.
  Future<AuthDataSourceResult> login(String identifier, String password);

  /// Completes a password sign-in that answered `requiresTwoFactor`.
  Future<AuthDataSourceResult> verifyTwoFactor(
    String twoFactorToken,
    String otp,
  );

  /// Asks the API to issue a one-time code for [phone].
  Future<String> requestPhoneOtp(String phone);

  /// Exchanges a phone number and its one-time code for a session.
  Future<AuthDataSourceResult> verifyPhoneOtp(String phone, String otp);

  /// Both registrations issue a session immediately and, for an email account,
  /// send a verification code.
  Future<AuthDataSourceResult> registerEmployee(EmployeeRegistration request);
  Future<AuthDataSourceResult> registerCompany(CompanyRegistration request);

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

  Future<void> logout();

  Future<CurrentUserResponse> fetchCurrentUser();
}
