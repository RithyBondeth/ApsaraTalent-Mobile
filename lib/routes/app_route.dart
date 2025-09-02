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
              page: ResumeBuilderRoute.page,
              path: 'resume-builder',
              initial: true,
            ),
          ],
        ),
      ];
}
