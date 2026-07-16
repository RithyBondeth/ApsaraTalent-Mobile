// Abstract interface for auth repository
abstract class AuthRepository {
  // Login with email and password
  Future<dynamic> login(String email, String password);
}
