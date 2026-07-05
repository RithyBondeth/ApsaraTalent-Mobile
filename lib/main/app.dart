import 'package:apsaratalent_mobile/core/constants/text_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routes/app_route.dart';
import '../core/themes/app_themes.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = AppRouter();

    return MaterialApp.router(
      title: AppTextConstant.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter.config(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
