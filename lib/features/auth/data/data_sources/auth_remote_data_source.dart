import 'package:apsaratalent_mobile/features/auth/data/models/login_response.dart';

abstract class AuthRemoteDataSource {
  // Login with email and password
  Future<LoginDataSourceResult> login(String email, String password);
}
