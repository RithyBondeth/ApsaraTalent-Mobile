// Use case for completing a two-factor sign-in
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import '../repositories/auth_repository.dart';

class VerifyTwoFactorUseCase {
  final AuthRepository _repository;

  VerifyTwoFactorUseCase(this._repository);

  Future<LoginResponse> call(
    String twoFactorToken,
    String otp, {
    required bool remember,
  }) {
    return _repository.verifyTwoFactor(twoFactorToken, otp, remember: remember);
  }
}
