import '../entities/message_entity.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<MessageEntity> call(String email) async {
    return await _repository.forgotPassword(email);
  }
}
