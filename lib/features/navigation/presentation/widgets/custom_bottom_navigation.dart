import 'package:apsaratalent_mobile/features/navigation/presentation/widgets/custom_bottom_navigation_item.dart';
import 'package:apsaratalent_mobile/features/navigation/providers/bottom_navigation_provider.dart';
import 'package:apsaratalent_mobile/shared/extensions/color_extensions.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomBottomNavigationBar extends ConsumerWidget {
  final TabsRouter tabsRouter;
  const CustomBottomNavigationBar({super.key, required this.tabsRouter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        color: context.primary,
        height: 80,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBottomNavigationItem(
                icon: LucideIcons.house,
                label: 'Feed',
                index: 0,
                ref: ref,
                item: BottomNavigationItem.feed,
                tabRouter: tabsRouter,
              ),
              CustomBottomNavigationItem(
                icon: LucideIcons.search,
                label: 'Search',
                index: 1,
                ref: ref,
                item: BottomNavigationItem.search,
                tabRouter: tabsRouter,
              ),
              CustomBottomNavigationItem(
                icon: LucideIcons.messageCircle,
                label: 'Chat',
                index: 2,
                ref: ref,
                item: BottomNavigationItem.chat,
                tabRouter: tabsRouter,
              ),
              CustomBottomNavigationItem(
                icon: LucideIcons.bot,
                label: 'Resume',
                index: 3,
                ref: ref,
                item: BottomNavigationItem.resume,
                tabRouter: tabsRouter,
              ),
              CustomBottomNavigationItem(
                icon: LucideIcons.settings,
                label: 'Setting',
                index: 4,
                ref: ref,
                item: BottomNavigationItem.setting,
                tabRouter: tabsRouter,
              ),
            ],
          ),
        ));
  }
}
