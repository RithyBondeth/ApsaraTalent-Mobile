import '../entities/message_entity.dart';

abstract class AuthRepository {
  Future<dynamic> login(String email, String password);
  Future<void> logout();
  Future<MessageEntity> forgotPassword(String email);
  Future<MessageEntity> resetPassword(String token, String password);
}
