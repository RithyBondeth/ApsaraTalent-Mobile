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
        AutoRoute(
          page: MainRoute.page,
          path: '/',
          initial: true,
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
