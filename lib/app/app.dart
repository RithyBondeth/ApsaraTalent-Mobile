import 'package:apsaratalent_mobile/core/configs/config_service.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_state.dart';
import 'package:apsaratalent_mobile/features/theme/providers/theme_provider.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/routes/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  // Held in state rather than rebuilt in `build`: a fresh AppRouter on every
  // rebuild throws away the navigation stack, so a theme change would bounce
  // the user back to the initial route.
  late final AppRouter _router = AppRouter(
    authGuard: AuthGuard(() => ref.read(authSessionProvider)),
  );

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    // Whenever a session ends — sign-out, or the API refusing a refresh
    // mid-use — send the user to login from wherever they are.
    ref.listen<AsyncValue<AuthSessionState>>(authSessionProvider, (prev, next) {
      final wasSignedIn = prev?.value?.isAuthenticated ?? false;
      final isSignedIn = next.value?.isAuthenticated ?? false;
      if (wasSignedIn && !isSignedIn) {
        _router.replaceAll([const LoginRoute()]);
      }
    });

    return MaterialApp.router(
      title: AppConfigService.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: _router.config(),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode.themeMode,
    );
  }
}
