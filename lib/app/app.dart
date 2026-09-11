import 'package:apsaratalent_mobile/core/configs/config_service.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/theme/providers/theme_provider.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
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
  final AppRouter _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

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
