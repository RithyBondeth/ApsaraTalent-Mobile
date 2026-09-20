import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:apsaratalent_mobile/features/notification/providers/notification_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// The record of what happened: matches, applications, interviews, messages.
@RoutePage()
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  /// How close to the bottom, in logical pixels, the next page starts loading.
  static const _loadMoreThreshold = 400.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final state = notifications.value;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (state?.loadMoreError == null &&
            notification.metrics.axis == Axis.vertical &&
            notification.metrics.extentAfter < _loadMoreThreshold) {
          notifier.loadMore();
        }
        return false;
      },
      child: AppScreen(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            if ((state?.unread ?? 0) > 0)
              TextButton(
                onPressed: () => _run(
                  context,
                  () => notifier.markAllRead(),
                ),
                child: const Text('Mark all read'),
              ),
            if ((state?.items.length ?? 0) > 0)
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 18),
                tooltip: 'Clear all',
                onPressed: () => _confirmClear(context, ref),
              ),
          ],
        ),
        onRefresh: () async => _run(context, () => notifier.refresh()),
        children: notifications.when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          loading: () => [
            for (var i = 0; i < 4; i++) const _RowSkeleton(),
          ],
          error: (error, _) => [
            PageState(
              variant: PageStateVariant.error,
              title: 'Your notifications could not load',
              description: error is ApiException
                  ? error.message
                  : 'Check your connection and try again.',
              actionLabel: 'Try again',
              onAction: () => ref.invalidate(notificationsProvider),
            ),
          ],
          data: (state) => _content(context, ref, state),
        ),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    WidgetRef ref,
    NotificationsState state,
  ) =>
      [
        PageBanner(
          eyebrow: 'Activity',
          title: 'What happened while you were away',
          stats: [
            PageBannerStat(
              icon: LucideIcons.bell,
              value: '${state.unread}',
              label: 'unread',
            ),
            PageBannerStat(
              icon: LucideIcons.inbox,
              // The API's total, not the number loaded so far.
              value: '${state.total}',
              label: 'total',
            ),
          ],
        ),
        if (state.items.isEmpty)
          const PageState(
            variant: PageStateVariant.empty,
            icon: LucideIcons.bellOff,
            title: 'Nothing new',
            description:
                'Matches, applications and interview invites land here.',
          )
        else
          for (final notification in state.items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppShape.space2),
              child: _NotificationRow(
                key: ValueKey(notification.id),
                notification: notification,
                busy: state.isPending(notification.id),
                onTap: () => _open(context, ref, notification),
                onDelete: () => _run(
                  context,
                  () => ref
                      .read(notificationsProvider.notifier)
                      .remove(notification),
                ),
              ),
            ),
        if (state.isLoadingMore)
          const _RowSkeleton()
        else if (state.loadMoreError != null)
          PageState(
            variant: PageStateVariant.error,
            compact: true,
            title: 'More could not load',
            description: state.loadMoreError,
            actionLabel: 'Try again',
            onAction: () =>
                ref.read(notificationsProvider.notifier).loadMore(),
          ),
        const SizedBox(height: AppShape.space6),
      ];

  /// Opening marks read, and takes the reader where the notification points —
  /// which today is only matches. The rest read as a record of what happened,
  /// because the screens they would open are not built yet.
  void _open(BuildContext context, WidgetRef ref, AppNotification n) {
    _run(context, () => ref.read(notificationsProvider.notifier).markRead(n));
    switch (n.kind) {
      case NotificationKind.match:
      case NotificationKind.like:
        context.router.push(const MatchRoute());
      case _:
        break;
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text(
          'Every notification is deleted for good. What they were about — '
          'your matches, applications and interviews — is not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep them'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _run(
      context,
      () => ref.read(notificationsProvider.notifier).clearAll(),
    );
  }

  static Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    super.key,
    required this.notification,
    required this.busy,
    required this.onTap,
    required this.onDelete,
  });

  final AppNotification notification;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final unread = !notification.isRead;

    return AppSurface(
      onTap: busy ? null : onTap,
      elevation: SurfaceElevation.sm,
      padding: const EdgeInsets.all(AppShape.space3),
      // An unread row is tinted rather than accent-edged. The edge is spent on
      // page identity and state; unread is neither, and a coloured bar on every
      // second row in a list is the texture problem all over again.
      color: unread ? t.accent.withValues(alpha: 0.35) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            color: t.muted,
            child: Icon(_icon(notification.kind), size: 16, color: t.foreground),
          ),
          const SizedBox(width: AppShape.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.kind.label.toUpperCase(),
                        style: AppTypography.eyebrow.copyWith(
                          color: t.mutedForeground,
                        ),
                      ),
                    ),
                    if (notification.age.isNotEmpty)
                      Text(
                        notification.age,
                        style: AppTypography.tiny.copyWith(
                          color: t.mutedForeground,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  notification.title,
                  style: AppTypography.label.copyWith(
                    color: t.foreground,
                    fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                if (notification.message case final message?) ...[
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: AppTypography.tiny.copyWith(
                      color: t.mutedForeground,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 16),
            tooltip: 'Delete',
            onPressed: busy ? null : onDelete,
          ),
        ],
      ),
    );
  }

  static IconData _icon(NotificationKind kind) => switch (kind) {
        NotificationKind.match || NotificationKind.like => LucideIcons.sparkles,
        NotificationKind.interview => LucideIcons.calendarCheck,
        NotificationKind.application => LucideIcons.send,
        NotificationKind.offer => LucideIcons.fileCheck,
        NotificationKind.chat => LucideIcons.messageCircle,
        NotificationKind.call => LucideIcons.phone,
        NotificationKind.info || NotificationKind.other => LucideIcons.info,
      };
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: AppShape.space2),
        child: AppSurface(
          elevation: SurfaceElevation.sm,
          padding: EdgeInsets.all(AppShape.space3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 32, height: 32),
              SizedBox(width: AppShape.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: 60, height: 8),
                    SizedBox(height: AppShape.space2),
                    AppSkeleton(width: 150, height: 12),
                    SizedBox(height: AppShape.space2),
                    AppSkeleton(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
