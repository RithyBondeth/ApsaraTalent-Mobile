import 'dart:async';

import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:apsaratalent_mobile/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:apsaratalent_mobile/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owns "is anyone signed in" for the whole app.
///
/// Its first value comes from restoring a remembered session at launch; the
/// splash screen waits on it and the route guard reads it. After that it moves
/// on sign-in ([establish]), sign-out ([signOut]), and whenever the API refuses
/// the session outright — which the network layer reports through
/// `SessionStore.expirations`, since core cannot depend on this feature.
class AuthSessionNotifier extends AsyncNotifier<AuthSessionState> {
  late AuthRepository _repository;

  @override
  Future<AuthSessionState> build() async {
    _repository = ref.watch(authRepositoryProvider);

    final expirations = ref.watch(sessionStoreProvider).expirations.listen((_) {
      state = const AsyncData(AuthSessionState.signedOut());
    });
    ref.onDispose(expirations.cancel);

    if (!await _repository.restoreSession()) {
      return const AuthSessionState.signedOut();
    }
    return _loadUser();
  }

  /// Call once a credential exchange has stored a session.
  Future<void> establish() async {
    state = AsyncData(await _loadUser());
  }

  Future<void> signOut() async {
    await LogoutUseCase(_repository)();

    // What the last user typed shouldn't greet the next one.
    ref
      ..invalidate(emailInputProvider)
      ..invalidate(passwordInputProvider)
      ..invalidate(rememberMeProvider)
      ..invalidate(loginProvider)
      ..invalidate(otpProvider);

    state = const AsyncData(AuthSessionState.signedOut());
  }

  Future<AuthSessionState> _loadUser() async {
    try {
      final user = await GetCurrentUserUseCase(_repository)();
      return AuthSessionState.signedIn(user);
    } on UnauthorizedException {
      // The interceptor has already tried a refresh; a 401 that survives it
      // means the session is gone.
      await ref.read(sessionStoreProvider).clear();
      return const AuthSessionState.signedOut();
    } on ApiException {
      // Offline, timed out, throttled or a 5xx: the session may be fine. Stay
      // signed in without a profile rather than throw the user out.
      return const AuthSessionState.signedIn(null);
    }
  }
}

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionNotifier, AuthSessionState>(
  AuthSessionNotifier.new,
);
