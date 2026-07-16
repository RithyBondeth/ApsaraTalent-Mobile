import 'user_entity.dart';

class AuthEntity {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}
