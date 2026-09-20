import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_avatar.dart';

/// The standard page frame: one gutter, one scroll view, one vertical rhythm.
///
/// Every signed-in screen uses this so the gutter cannot drift between pages —
/// a 16pt page next to a 20pt one is the kind of difference nobody can name but
/// everybody notices when scrolling between tabs.
class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.children,
    this.appBar,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppShape.screenPadding,
      vertical: AppShape.space4,
    ),
    this.gap = AppShape.space4,
    this.scrollable = true,
    this.onRefresh,
  });

  final List<Widget> children;
  final PreferredSizeWidget? appBar;
  final EdgeInsetsGeometry padding;

  /// Vertical space inserted between each child. Set to 0 and space by hand
  /// when a screen needs an irregular rhythm.
  final double gap;

  final bool scrollable;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (gap > 0 && i != children.length - 1) {
        spaced.add(SizedBox(height: gap));
      }
    }

    Widget body = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spaced,
      ),
    );

    if (scrollable) {
      body = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: body,
      );
      if (onRefresh != null) {
        body = RefreshIndicator(
          onRefresh: onRefresh!,
          color: context.tokens.primary,
          backgroundColor: context.tokens.card,
          child: body,
        );
      }
    }

    return Scaffold(
      backgroundColor: context.tokens.background,
      appBar: appBar,
      body: SafeArea(child: body),
    );
  }
}

/// The signed-in header: who you are on the left, notifications on the right.
///
/// The avatar and name double as the link to your own profile, which is why
/// there is no separate profile tab competing for a slot in the bar.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.name,
    required this.subtitle,
    this.avatarUrl,
    this.unreadCount = 0,
    this.onProfileTap,
    this.onNotificationsTap,
  });

  final String name;
  final String subtitle;
  final String? avatarUrl;
  final int unreadCount;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AppBar(
      backgroundColor: t.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 68,
      automaticallyImplyLeading: false,
      titleSpacing: AppShape.screenPadding,
      title: GestureDetector(
        onTap: onProfileTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            AppAvatar(name: name, imageUrl: avatarUrl, size: AppAvatarSize.md),
            const SizedBox(width: AppShape.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      color: t.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.tiny.copyWith(
                      color: t.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        _NotificationBell(
          count: unreadCount,
          onTap: onNotificationsTap,
        ),
        const SizedBox(width: AppShape.space2),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count, this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 48,
        width: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, color: t.foreground),
            if (count > 0)
              Positioned(
                top: 10,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: t.destructive,
                    borderRadius: BorderRadius.circular(AppShape.pill),
                  ),
                  child: Text(
                    // A three-digit count would stretch the dot into a lozenge
                    // wider than the icon it sits on.
                    count > 9 ? '9+' : '$count',
                    textAlign: TextAlign.center,
                    style: AppTypography.tiny.copyWith(
                      color: t.destructiveForeground,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
