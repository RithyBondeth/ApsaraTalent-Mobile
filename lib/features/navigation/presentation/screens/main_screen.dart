import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/features/navigation/presentation/widgets/app_bottom_navigation.dart';

@RoutePage()
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsScaffold(
      backgroundColor: context.tokens.background,
      routes: const [
        FeedRoute(),
        SearchRoute(),
        ChatRoute(),
        ResumeBuilderRoute(),
        SettingRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) =>
          AppBottomNavigation(tabsRouter: tabsRouter),
    );
  }
}
