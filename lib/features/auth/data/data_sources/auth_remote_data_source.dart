import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/login_request.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/message_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> logout();
  Future<MessageResponse> forgotPassword(String email);
  Future<MessageResponse> resetPassword(String token, String password);
}
