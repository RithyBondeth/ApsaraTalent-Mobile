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
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = SampleData.conversations;
    final unread = conversations.fold<int>(0, (sum, c) => sum + c.unread);

    return AppScreen(
      children: [
        PageBanner(
          eyebrow: 'Messages',
          title: 'Conversations with hiring teams',
          subtitle:
              'Replies from companies you have applied to, plus anyone who has '
              'reached out about your profile.',
          stats: [
            PageBannerStat(
              icon: LucideIcons.messageCircle,
              value: '${conversations.length}',
              label: 'threads',
            ),
            PageBannerStat(
              icon: LucideIcons.mailOpen,
              value: '$unread',
              label: 'unread',
            ),
          ],
        ),

        if (conversations.isEmpty)
          const PageState(
            variant: PageStateVariant.empty,
            icon: LucideIcons.messageCircleOff,
            title: 'No conversations yet',
            description:
                'When a company replies to an application, the thread shows up '
                'here.',
          )
        else
          for (final conversation in conversations)
            Padding(
              padding: const EdgeInsets.only(bottom: AppShape.space2),
              child: _ConversationRow(conversation: conversation),
            ),
      ],
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.conversation});

  final SampleConversation conversation;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hasUnread = conversation.unread > 0;

    return AppSurface(
      onTap: () {},
      elevation: SurfaceElevation.sm,
      padding: const EdgeInsets.all(AppShape.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AppAvatar(name: conversation.name, size: AppAvatarSize.md),
              if (conversation.online)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 11,
                    width: 11,
                    decoration: BoxDecoration(
                      // Presence is genuinely a state, so the success token is
                      // the right borrow here — unlike, say, an employment type.
                      color: t.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.card, width: 2),
                    ),
                  ),
                ),
            ],
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
                        conversation.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(
                          color: t.foreground,
                          fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppShape.space2),
                    Text(
                      conversation.timeAgo,
                      style: AppTypography.tiny.copyWith(
                        color: t.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  conversation.company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.tiny.copyWith(
                    color: t.mutedForeground,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: AppShape.space2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        conversation.preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.tiny.copyWith(
                          color: hasUnread ? t.foreground : t.mutedForeground,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (hasUnread) ...[
                      const SizedBox(width: AppShape.space2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: t.primary,
                          borderRadius: BorderRadius.circular(AppShape.pill),
                        ),
                        child: Text(
                          '${conversation.unread}',
                          style: AppTypography.tiny.copyWith(
                            color: t.primaryForeground,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
