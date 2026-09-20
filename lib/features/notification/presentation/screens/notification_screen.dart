import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/shared/data/sample_data.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

@RoutePage()
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = SampleData.notifications;
    final unread = notifications.where((n) => n.unread).length;

    return AppScreen(
      appBar: AppBar(title: const Text('Notifications')),
      children: [
        PageBanner(
          eyebrow: 'Activity',
          title: 'What happened while you were away',
          stats: [
            PageBannerStat(
              icon: LucideIcons.bell,
              value: '$unread',
              label: 'unread',
            ),
            PageBannerStat(
              icon: LucideIcons.inbox,
              value: '${notifications.length}',
              label: 'total',
            ),
          ],
        ),

        if (notifications.isEmpty)
          const PageState(
            variant: PageStateVariant.empty,
            icon: LucideIcons.bellOff,
            title: 'Nothing new',
            description:
                'Interview invites, matches and profile views land here.',
          )
        else
          for (final notification in notifications)
            Padding(
              padding: const EdgeInsets.only(bottom: AppShape.space2),
              child: _NotificationRow(notification: notification),
            ),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});

  final SampleNotification notification;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AppSurface(
      onTap: () {},
      elevation: SurfaceElevation.sm,
      padding: const EdgeInsets.all(AppShape.space3),
      // An unread row is tinted rather than accent-edged. The edge is spent on
      // page identity and state; unread is neither, and a coloured bar on every
      // second row in a list is the texture problem all over again.
      color: notification.unread ? t.accent.withValues(alpha: 0.35) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.muted,
              border: Border.all(color: t.border, width: AppShape.hairline),
            ),
            child: Icon(
              notification.icon,
              size: 17,
              color: t.mutedForeground,
            ),
          ),
          const SizedBox(width: AppShape.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTypography.label.copyWith(
                          color: t.foreground,
                          fontWeight: notification.unread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppShape.space2),
                    Text(
                      notification.timeAgo,
                      style: AppTypography.tiny.copyWith(
                        color: t.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppShape.space1),
                Text(
                  notification.body,
                  style: AppTypography.tiny.copyWith(
                    color: t.mutedForeground,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppShape.space2),
                // Notification *type* is a kind, not a severity — categorical,
                // never a status pill.
                AppCategoryChip(
                  category: notification.category,
                  label: notification.kind,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
