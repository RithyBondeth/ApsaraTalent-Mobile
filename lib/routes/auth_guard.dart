import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_state.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeps signed-in screens behind a session.
///
/// Mostly this matters for entries that skip the splash — a deep link, or
/// state restoration — and for anything pushed after a session has expired.
/// A session still being restored sends the navigation to the splash, which
/// finishes the restore and routes from there.
class AuthGuard extends AutoRouteGuard {
  AuthGuard(this._readSession);

  final AsyncValue<AuthSessionState> Function() _readSession;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final session = _readSession();
    if (session.value?.isAuthenticated == true) {
      resolver.next();
      return;
    }

    resolver.next(false);
    // Replace the stack after this navigation has unwound. When the guarded
    // route is the app's very first one, the navigator is not mounted yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.root.replaceAll([
        if (session.isLoading) const SplashRoute() else const LoginRoute(),
      ]);
    });
  }
}
