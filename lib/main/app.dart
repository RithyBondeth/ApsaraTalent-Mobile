import 'package:apsaratalent_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:apsaratalent_mobile/shared/constants/text_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import '../routes/app_route.dart';
import '../shared/themes/app_themes.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final appRouter = AppRouter();

    return MaterialApp(
      title: AppTextConstant.appName,
      debugShowCheckedModeBanner: false,
      //routerConfig: appRouter.config(),
      home: LoginScreen(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
