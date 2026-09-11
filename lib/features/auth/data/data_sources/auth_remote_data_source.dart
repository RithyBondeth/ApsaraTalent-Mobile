import 'package:apsaratalent_mobile/features/auth/data/models/current_user_response.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';

abstract class AuthRemoteDataSource {
  /// Password sign-in. [identifier] is an email address or a phone number —
  /// the API's login DTO takes either under the one field.
  Future<AuthDataSourceResult> login(String identifier, String password);

  /// Completes a password sign-in that answered `requiresTwoFactor`.
  Future<AuthDataSourceResult> verifyTwoFactor(
    String twoFactorToken,
    String otp,
  );

  Future<void> logout();

  Future<CurrentUserResponse> fetchCurrentUser();
}
