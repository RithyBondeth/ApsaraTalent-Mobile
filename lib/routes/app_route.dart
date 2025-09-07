import 'package:apsaratalent_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/phone_number_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/signup_screens/career_scopes_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/signup_screens/company_signup_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/signup_screens/employee_signup_screen.dart';
import 'package:apsaratalent_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/screens/feed_screen.dart';
import 'package:apsaratalent_mobile/features/search/presentation/screens/search_screen.dart';
import 'package:apsaratalent_mobile/features/setting/presentation/screens/setting_page.dart';
import 'package:apsaratalent_mobile/shared/constants/route_contant.dart';
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
          path: AuthRouteConstant.loginPath,
          initial: true,
        ),
        AutoRoute(
          page: ForgotPasswordRoute.page,
          path: AuthRouteConstant.forgotPasswordPath,
        ),
        AutoRoute(
          page: ResetPasswordRoute.page,
          path: AuthRouteConstant.resetPasswordPath,
        ),
        AutoRoute(
          page: PhoneNumberRoute.page,
          path: AuthRouteConstant.phoneNumberLoginPath,
        ),
        AutoRoute(
          page: OTPRoute.page,
          path: AuthRouteConstant.phoneOTPPath,
        ),
        AutoRoute(
          page: EmployeeSignupRoute.page,
          path: AuthRouteConstant.employeeSignupPath,
        ),
        AutoRoute(
          page: CompanySignupRoute.page,
          path: AuthRouteConstant.companySignupPath,
        ),
        AutoRoute(
          page: CareerScopeRoute.page,
          path: AuthRouteConstant.careerScopePath,
        ),
        // Main app routes
        AutoRoute(
          page: MainRoute.page,
          path: MainRouteConstant.homePath,
          children: [
            AutoRoute(
              page: FeedRoute.page,
              path: MainRouteConstant.feedPath,
              initial: true,
            ),
            AutoRoute(
              page: SearchRoute.page,
              path: MainRouteConstant.searchPath,
            ),
            AutoRoute(
              page: ChatRoute.page,
              path: MainRouteConstant.chatPath,
            ),
            AutoRoute(
              page: ResumeBuilderRoute.page,
              path: MainRouteConstant.resumeBuilderPath,
            ),
            AutoRoute(
              page: SettingRoute.page,
              path: MainRouteConstant.settingPath,
            ),
          ],
        ),
      ];
}
