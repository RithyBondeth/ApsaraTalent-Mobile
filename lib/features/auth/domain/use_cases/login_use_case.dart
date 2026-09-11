// Use case for login
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  // Execute login
  Future<LoginResponse> call(
    String identifier,
    String password, {
    required bool remember,
  }) {
    return _repository.login(identifier, password, remember: remember);
  }
}
