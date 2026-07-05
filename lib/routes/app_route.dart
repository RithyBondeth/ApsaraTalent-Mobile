import 'package:apsaratalent_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/phone_number_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:apsaratalent_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/screens/feed_screen.dart';
import 'package:apsaratalent_mobile/features/search/presentation/screens/search_screen.dart';
import 'package:apsaratalent_mobile/features/setting/presentation/screens/setting_page.dart';
import 'package:apsaratalent_mobile/core/constants/routes_path_contant.dart';
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
          path: AuthRoutesPathConstant.loginPath,
          initial: true,
        ),
        AutoRoute(
          page: ForgotPasswordRoute.page,
          path: AuthRoutesPathConstant.forgotPasswordPath,
        ),
        AutoRoute(
          page: ResetPasswordRoute.page,
          path: AuthRoutesPathConstant.resetPasswordPath,
        ),
        AutoRoute(
          page: PhoneNumberRoute.page,
          path: AuthRoutesPathConstant.phoneNumberLoginPath,
        ),
        AutoRoute(
          page: OTPRoute.page,
          path: AuthRoutesPathConstant.phoneOTPPath,
        ),
        // Main app routes
        AutoRoute(
          page: MainRoute.page,
          path: MainRoutesPathConstant.homePath,
          // initial: true,
          children: [
            AutoRoute(
              page: FeedRoute.page,
              path: MainRoutesPathConstant.feedPath,
              initial: true,
            ),
            AutoRoute(
              page: SearchRoute.page,
              path: MainRoutesPathConstant.searchPath,
            ),
            AutoRoute(
              page: ChatRoute.page,
              path: MainRoutesPathConstant.chatPath,
            ),
            AutoRoute(
              page: ResumeBuilderRoute.page,
              path: MainRoutesPathConstant.resumeBuilderPath,
            ),
            AutoRoute(
              page: SettingRoute.page,
              path: MainRoutesPathConstant.settingPath,
            ),
          ],
        ),
      ];
}
