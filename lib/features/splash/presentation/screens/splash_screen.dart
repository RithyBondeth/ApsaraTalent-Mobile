import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_state.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_logo.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The first route. Holds the mark on screen while a remembered session is
/// restored, then hands off to the feed or to login.
///
/// Without it the app would open on login and jump to the feed a beat later for
/// everyone who is already signed in — a flash of the wrong screen on every
/// launch.
@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _routed = false;

  void _route(AuthSessionState session) {
    if (_routed || !mounted) return;
    _routed = true;
    context.router.replaceAll([
      if (session.isAuthenticated) const MainRoute() else const LoginRoute(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    // Restoring may already be done by the time this mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(authSessionProvider).value;
      if (session != null) _route(session);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthSessionState>>(authSessionProvider, (_, next) {
      final session = next.value;
      if (session != null) _route(session);
    });

    return Scaffold(
      backgroundColor: context.tokens.background,
      body: const Center(child: AppLogo(height: 88)),
    );
  }
}
