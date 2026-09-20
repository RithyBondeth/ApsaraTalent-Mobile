import 'package:apsaratalent_mobile/features/auth/domain/entities/current_user_entity.dart';

/// Whether anyone is signed in, and who.
class AuthSessionState {
  const AuthSessionState._({required this.isAuthenticated, this.user});

  const AuthSessionState.signedOut() : this._(isAuthenticated: false);

  /// [user] can be null while [isAuthenticated] is true: the session is valid
  /// but the profile couldn't be loaded — offline at launch, say. Signing
  /// someone out because the network is down would be wrong.
  const AuthSessionState.signedIn(CurrentUserEntity? user)
      : this._(isAuthenticated: true, user: user);

  final bool isAuthenticated;
  final CurrentUserEntity? user;
}
