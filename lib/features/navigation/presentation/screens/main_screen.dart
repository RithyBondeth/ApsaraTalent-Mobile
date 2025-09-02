import 'package:apsaratalent_mobile/features/navigation/presentation/widgets/custom_bottom_navigation.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AutoTabsScaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        routes: const [
          ResumeBuilderRoute(),
        ],
        bottomNavigationBuilder: (context, tabsRouter) {
          return CustomBottomNavigationBar(tabsRouter: tabsRouter);
        },
      ),
    );
  }
}
