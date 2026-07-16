import 'user_auth_entity.dart';

class LoginSuccessEntity {
  final String message;
  final UserAuthEntity user;

  LoginSuccessEntity({required this.message, required this.user});
}

class LoginTwoFactorEntity {
  final String message;
  final String userId;

  LoginTwoFactorEntity({required this.message, required this.userId});
}
