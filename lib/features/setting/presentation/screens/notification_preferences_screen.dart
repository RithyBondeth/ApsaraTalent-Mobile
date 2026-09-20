import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/setting/domain/entities/notification_preferences.dart';
import 'package:apsaratalent_mobile/features/setting/providers/notification_preferences_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// Which notifications reach the viewer, and how.
///
/// Every switch writes on its own, immediately — there is no save button,
/// because the API takes a partial update per toggle and answers with the
/// resolved state.
@RoutePage()
class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return AppScreen(
      appBar: AppBar(title: const Text('Notifications')),
      onRefresh: () async {
        try {
          await notifier.refresh();
        } on ApiException catch (e) {
          if (context.mounted) _snack(context, e.message);
        }
      },
      children: state.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const [_Skeleton()],
        error: (error, _) => [
          PageState(
            variant: PageStateVariant.error,
            title: 'Your notification settings could not load',
            description: error is ApiException
                ? error.message
                : 'Check your connection and try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(notificationPreferencesProvider),
          ),
        ],
        data: (state) => _content(context, ref, state),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    WidgetRef ref,
    PreferencesState state,
  ) {
    final t = context.tokens;
    final preferences = state.preferences;

    return [
      const PageBanner(
        eyebrow: 'Notifications',
        title: 'What reaches you, and how',
        subtitle: 'Each switch saves on its own. Security messages are always '
            'sent.',
      ),

      const SectionTitle(
        title: 'Channels',
        subtitle: 'Turning one off silences every category below it',
      ),
      AppSurface(
        child: Column(
          children: [
            for (final channel in NotificationChannel.values) ...[
              if (channel != NotificationChannel.values.first)
                Divider(color: t.border, height: AppShape.space4),
              _SwitchRow(
                label: '${channel.label} notifications',
                // The app has no push capability yet: nothing registers a
                // device token, so nothing arrives here whatever this says.
                // The preference is still the user's and still governs other
                // clients, so it is offered — with the limitation stated.
                description: channel == NotificationChannel.push
                    ? 'Saved, but this app cannot receive push yet'
                    : 'Sent to your account email',
                value: preferences.master(channel),
                busy: state.isSaving(masterKey(channel)),
                onChanged: (value) => _set(
                  context,
                  () => ref
                      .read(notificationPreferencesProvider.notifier)
                      .setMaster(channel, value),
                ),
              ),
            ],
          ],
        ),
      ),

      const SectionTitle(
        title: 'Categories',
        subtitle: 'What each kind of notification may use',
      ),
      for (final category in NotificationCategory.values)
        _CategoryCard(
          category: category,
          state: state,
          onChanged: (channel, value) => _set(
            context,
            () => ref
                .read(notificationPreferencesProvider.notifier)
                .setCategory(category, channel, value),
          ),
        ),
      const SizedBox(height: AppShape.space6),
    ];
  }

  Future<void> _set(BuildContext context, Future<void> Function() write) async {
    try {
      await write();
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, e.message);
    }
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.state,
    required this.onChanged,
  });

  final NotificationCategory category;
  final PreferencesState state;
  final void Function(NotificationChannel, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final preferences = state.preferences;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space3),
      child: AppSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.label,
                    style: AppTypography.label.copyWith(color: t.foreground),
                  ),
                ),
                if (category.isAlwaysOn)
                  MetaChip(icon: LucideIcons.lock, label: 'Always on'),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              category.description,
              style: AppTypography.tiny.copyWith(color: t.mutedForeground),
            ),
            const SizedBox(height: AppShape.space3),
            for (final channel in NotificationChannel.values)
              _SwitchRow(
                label: channel.label,
                // Neither of these switches changes what arrives, so both are
                // disabled — but they read differently on purpose.
                //
                // Under a master that is off, the stored choice is shown as
                // it is: it comes back when the master returns.
                //
                // Account is shown as on regardless of what is stored. The
                // API accepts `account: {email: false}` and keeps it, but
                // `canDeliver` answers true for ACCOUNT without consulting
                // anything — so the stored value is not what happens, and a
                // switch showing "off" beside a password-reset email that
                // still arrives would be the lie, not this.
                description: category.isAlwaysOn
                    ? 'Sent whatever this says'
                    : preferences.master(channel)
                        ? null
                        : '${channel.label} notifications are off',
                value: category.isAlwaysOn
                    ? true
                    : preferences.isOn(category, channel),
                busy: state.isSaving(categoryKey(category, channel)),
                enabled: preferences.isEffective(category, channel),
                dense: true,
                onChanged: (value) => onChanged(channel, value),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.busy = false,
    this.enabled = true,
    this.dense = false,
  });

  final String label;
  final String? description;
  final bool value;
  final bool busy;
  final bool enabled;
  final bool dense;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final live = enabled && !busy;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 2 : 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: (dense ? AppTypography.small : AppTypography.label)
                      .copyWith(
                    color: enabled ? t.foreground : t.mutedForeground,
                  ),
                ),
                if (description case final description?) ...[
                  const SizedBox(height: 1),
                  Text(
                    description,
                    style: AppTypography.tiny.copyWith(
                      color: t.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: live ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: 180, height: 16),
                SizedBox(height: AppShape.space3),
                AppSkeleton(width: 140, height: 12),
              ],
            ),
          ),
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: 120, height: 14),
                SizedBox(height: AppShape.space3),
                AppSkeleton(height: 12),
                SizedBox(height: AppShape.space3),
                AppSkeleton(height: 12),
              ],
            ),
          ),
        ],
      );
}
