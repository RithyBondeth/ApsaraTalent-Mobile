// Abstract interface for auth repository
import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';

abstract class AuthRepository {
  // Login with email and password
  Future<LoginResponse> login(String email, String password);
}
