import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/features/navigation/providers/bottom_navigation_provider.dart';

/// The tab bar.
///
/// The active item is a filled-primary tile casting `elevation.primary` —
/// a foreground-coloured shadow under a coloured fill reads as grime, so a
/// filled surface casts its own hue instead. That is the one place in the app
/// where the primary elevation step is used.
///
/// The bar sits on the page background with a hairline top edge rather than a
/// solid primary slab. The previous version filled the whole bar with
/// `primary`, which put the app's single loudest colour along the bottom of
/// every screen and left nothing to distinguish the tab you were actually on —
/// the selected state was, in fact, never drawn.
class AppBottomNavigation extends ConsumerWidget {
  const AppBottomNavigation({super.key, required this.tabsRouter});

  final TabsRouter tabsRouter;

  static const _items = <_NavItem>[
    _NavItem(LucideIcons.house, 'Feed', BottomNavigationItem.feed),
    _NavItem(LucideIcons.search, 'Search', BottomNavigationItem.search),
    _NavItem(LucideIcons.messageCircle, 'Chat', BottomNavigationItem.chat),
    _NavItem(LucideIcons.fileText, 'Resume', BottomNavigationItem.resume),
    _NavItem(LucideIcons.settings, 'Setting', BottomNavigationItem.setting),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: t.background,
        border: Border(
          top: BorderSide(color: t.border, width: AppShape.hairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppShape.space2,
            vertical: AppShape.space2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: _items[i],
                    selected: tabsRouter.activeIndex == i,
                    onTap: () {
                      tabsRouter.setActiveIndex(i);
                      ref.read(bottomNavigationProvider.notifier).state =
                          _items[i].item;
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label, this.item);

  final IconData icon;
  final String label;
  final BottomNavigationItem item;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final foreground = selected ? t.primaryForeground : t.mutedForeground;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: AppShape.space2),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: selected ? t.primary : Colors.transparent,
          boxShadow: selected ? context.elevation.primaryXs : const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 20, color: foreground),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.tiny.copyWith(
                color: foreground,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
