import 'package:apsaratalent_mobile/features/navigation/providers/bottom_navigation_provider.dart';
import 'package:apsaratalent_mobile/shared/extensions/color_extensions.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBottomNavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final BottomNavigationItem item;
  final WidgetRef ref;
  final TabsRouter tabRouter;
  const CustomBottomNavigationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.item,
    required this.ref,
    required this.tabRouter,
  });

  @override
  Widget build(BuildContext context) {
    //final isSelected = tabRouter.activeIndex == index;

    return InkWell(
      onTap: () {
        tabRouter.setActiveIndex(index);
        ref.read(bottomNavigationProvider.notifier).state == item;
      },
      child: Column(
        children: [
          Icon(
            icon,
            size: 25,
            color: context.primaryForeground,
          ),
          Text(label,
              style: TextStyle(
                color: context.primaryForeground,
              )),
        ],
      ),
    );
  }
}
