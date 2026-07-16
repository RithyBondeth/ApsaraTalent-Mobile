import '../entities/message_entity.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<MessageEntity> call(String token, String password) async {
    return await _repository.resetPassword(token, password);
  }
}
