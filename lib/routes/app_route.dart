import 'package:apsaratalent_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:apsaratalent_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/screens/feed_screen.dart';
import 'package:apsaratalent_mobile/features/search/presentation/screens/search_screen.dart';
import 'package:apsaratalent_mobile/features/setting/presentation/screens/setting_page.dart';
import 'package:auto_route/auto_route.dart';
import '../features/navigation/presentation/screens/main_screen.dart';
import '../features/resume_builder/presentation/screens/resume_builder_screen.dart';

part 'app_route.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // Auth routes
        AutoRoute(
          page: LoginRoute.page,
          path: '/login',
          initial: true,
        ),
        AutoRoute(
          page: ForgotPasswordRoute.page,
          path: '/forgot-password',
        ),
        AutoRoute(
          page: ResetPasswordRoute.page,
          path: '/reset-password',
        ),
        // Main app routes
        AutoRoute(
          page: MainRoute.page,
          path: '/home',
          children: [
            AutoRoute(
              page: FeedRoute.page,
              path: 'feed',
              initial: true,
            ),
            AutoRoute(
              page: SearchRoute.page,
              path: 'search',
            ),
            AutoRoute(
              page: ChatRoute.page,
              path: 'chat',
            ),
            AutoRoute(
              page: ResumeBuilderRoute.page,
              path: 'resume-builder',
            ),
            AutoRoute(
              page: SettingRoute.page,
              path: 'setting',
            ),
          ],
        ),
      ];
}
