import 'package:apsaratalent_mobile/core/constants/route_path_contant.dart';
import 'package:apsaratalent_mobile/features/application/presentation/screens/application_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/phone_number_screen.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:apsaratalent_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:apsaratalent_mobile/features/favorite/presentation/screens/favorite_screen.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/screens/feed_screen.dart';
import 'package:apsaratalent_mobile/features/job/presentation/screens/job_detail_screen.dart';
import 'package:apsaratalent_mobile/features/navigation/presentation/screens/main_screen.dart';
import 'package:apsaratalent_mobile/features/notification/presentation/screens/notification_screen.dart';
import 'package:apsaratalent_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:apsaratalent_mobile/features/resume_builder/presentation/screens/resume_builder_screen.dart';
import 'package:apsaratalent_mobile/features/search/presentation/screens/search_screen.dart';
import 'package:apsaratalent_mobile/features/setting/presentation/screens/setting_page.dart';
import 'package:apsaratalent_mobile/shared/data/sample_data.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

part 'app_route.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // Auth routes
        AutoRoute(
          page: LoginRoute.page,
          path: RoutePathConstant.loginPath,
          initial: true,
        ),
        AutoRoute(
          page: ForgotPasswordRoute.page,
          path: RoutePathConstant.forgotPasswordPath,
        ),
        AutoRoute(
          page: ResetPasswordRoute.page,
          path: RoutePathConstant.resetPasswordPath,
        ),
        AutoRoute(
          page: PhoneNumberRoute.page,
          path: RoutePathConstant.phoneNumberLoginPath,
        ),
        AutoRoute(
          page: OTPRoute.page,
          path: RoutePathConstant.phoneOTPPath,
        ),

        // Main app routes
        AutoRoute(
          page: MainRoute.page,
          path: RoutePathConstant.homePath,
          children: [
            AutoRoute(
              page: FeedRoute.page,
              path: RoutePathConstant.feedPath,
              initial: true,
            ),
            AutoRoute(
              page: SearchRoute.page,
              path: RoutePathConstant.searchPath,
            ),
            AutoRoute(
              page: ChatRoute.page,
              path: RoutePathConstant.chatPath,
            ),
            AutoRoute(
              page: ResumeBuilderRoute.page,
              path: RoutePathConstant.resumeBuilderPath,
            ),
            AutoRoute(
              page: SettingRoute.page,
              path: RoutePathConstant.settingPath,
            ),
          ],
        ),

        // Detail routes — pushed over the tabs, not into them.
        AutoRoute(
          page: NotificationRoute.page,
          path: RoutePathConstant.notificationPath,
        ),
        AutoRoute(
          page: ProfileRoute.page,
          path: RoutePathConstant.profilePath,
        ),
        AutoRoute(
          page: ApplicationRoute.page,
          path: RoutePathConstant.applicationPath,
        ),
        AutoRoute(
          page: FavoriteRoute.page,
          path: RoutePathConstant.favoritePath,
        ),
        AutoRoute(
          page: JobDetailRoute.page,
          path: RoutePathConstant.jobDetailPath,
        ),
      ];
}
