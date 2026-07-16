// Use case for login
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  // Execute login
  Future<dynamic> call(String email, String password) async {
    return await _repository.login(email, password);
  }
}
