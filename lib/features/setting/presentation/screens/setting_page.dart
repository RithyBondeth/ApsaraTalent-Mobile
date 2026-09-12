import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/data/sample_data.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:apsaratalent_mobile/core/enums/theme_enum.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/theme/providers/theme_provider.dart';

@RoutePage()
class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final user = ref.watch(authSessionProvider).value?.user;
    final name = user?.displayName ?? 'Your account';
    final themeMode = ref.watch(themeModeProvider);

    return AppScreen(
      children: [
        const PageBanner(
          eyebrow: 'Settings',
          title: 'Account and preferences',
          subtitle:
              'How the app looks, what it tells you about, and who can see '
              'your profile.',
        ),

        // Identity Section
        AppSurface(
          onTap: () => context.router.push(const ProfileRoute()),
          child: Row(
            children: [
              AppAvatar(
                name: name,
                imageUrl: user?.avatarUrl,
                size: AppAvatarSize.lg,
              ),
              const SizedBox(width: AppShape.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.label.copyWith(
                        color: t.foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: AppTypography.base,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.headline ?? user?.email ?? '',
                      style: AppTypography.tiny.copyWith(
                        color: t.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 18, color: t.mutedForeground),
            ],
          ),
        ),

        // Appearance Section
        const SectionTitle(
          title: 'Appearance',
          subtitle: 'The palette is contrast-solved in both themes',
        ),
        _SettingGroup(
          children: [
            // Listed explicitly rather than from `.values`: the enum is
            // declared light/dark/system, and the default belongs first.
            for (final mode in const [
              EThemeModeType.system,
              EThemeModeType.light,
              EThemeModeType.dark,
            ])
              _ThemeOption(
                mode: mode,
                selected: themeMode == mode,
                onTap: () => ref.read(themeModeProvider.notifier).set(mode),
              ),
          ],
        ),

        // Activity Section
        const SectionTitle(title: 'Activity'),
        _SettingGroup(
          children: [
            _SettingRow(
              icon: LucideIcons.send,
              label: 'Applications',
              value: '${SampleData.applications.length} in flight',
              onTap: () => context.router.push(const ApplicationRoute()),
            ),
            _SettingRow(
              icon: LucideIcons.bookmark,
              label: 'Saved jobs',
              value: 'Roles you bookmarked',
              onTap: () => context.router.push(const FavoriteRoute()),
            ),
            _SettingRow(
              icon: LucideIcons.bell,
              label: 'Notifications',
              value:
                  '${SampleData.notifications.where((n) => n.unread).length} unread',
              onTap: () => context.router.push(const NotificationRoute()),
            ),
          ],
        ),

        // Account Section
        const SectionTitle(title: 'Account'),
        _SettingGroup(
          children: [
            _SettingRow(
              icon: LucideIcons.shield,
              label: 'Privacy',
              value: 'Who can see your profile',
              onTap: () {},
            ),
            _SettingRow(
              icon: LucideIcons.globe,
              label: 'Language',
              value: 'English',
              onTap: () {},
            ),
            _SettingRow(
              icon: LucideIcons.circleHelp,
              label: 'Support',
              value: 'Report a problem',
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: AppShape.space2),
        AppButton(
          label: 'Log out',
          icon: LucideIcons.logOut,
          variant: AppButtonVariant.outline,
          fullWidth: true,
          // The app-level session listener routes to login once this lands.
          onPressed: () => ref.read(authSessionProvider.notifier).signOut(),
        ),
        const SizedBox(height: AppShape.space6),
      ],
    );
  }
}

/// Rows share one surface with hairline dividers between them, rather than each
/// row being its own card. Five stacked cards on the web settings page is what
/// turned the surface accent into texture; the same over-articulation on a
/// phone costs a whole screen of vertical space to say nothing.
class _SettingGroup extends StatelessWidget {
  const _SettingGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(Divider(color: t.border, height: AppShape.hairline));
      }
    }

    return AppSurface(
      padding: EdgeInsets.zero,
      child: Column(children: rows),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppShape.space4,
          vertical: AppShape.space3,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: t.mutedForeground),
            const SizedBox(width: AppShape.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.label.copyWith(color: t.foreground),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    style: AppTypography.tiny.copyWith(
                      color: t.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: t.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final EThemeModeType mode;
  final bool selected;
  final VoidCallback onTap;

  (IconData, String, String) get _copy => switch (mode) {
        EThemeModeType.system => (
            LucideIcons.smartphone,
            'Match device',
            'Follows your system setting',
          ),
        EThemeModeType.light => (
            LucideIcons.sun,
            'Light',
            'White page, warm-grey ink',
          ),
        EThemeModeType.dark => (
            LucideIcons.moon,
            'Dark',
            'Near-black page with layered surfaces',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (icon, label, description) = _copy;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppShape.space4,
          vertical: AppShape.space3,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? t.primary : t.mutedForeground,
            ),
            const SizedBox(width: AppShape.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.label.copyWith(
                      color: t.foreground,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    description,
                    style: AppTypography.tiny.copyWith(
                      color: t.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(LucideIcons.check, size: 18, color: t.primary),
          ],
        ),
      ),
    );
  }
}
