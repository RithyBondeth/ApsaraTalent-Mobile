import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/features/chat/providers/chat_controller.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

@RoutePage()
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chat = ref.watch(chatControllerProvider);
    return AppScreen(onRefresh: chat.refresh, children: [
      PageBanner(
          eyebrow: 'Messages',
          title: 'Your conversations',
          subtitle: chat.connected
              ? 'Talk with the people you have matched with.'
              : 'Connecting to messages…'),
      Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
              onPressed: () => context.router.push(const MatchRoute()),
              icon: const Icon(Icons.add_comment_outlined),
              label: Text(context.tr('Message a match')))),
      if (chat.error != null)
        PageState(
            variant: PageStateVariant.error,
            title: 'Messages need attention',
            description: chat.error,
            actionLabel: 'Try again',
            onAction: chat.start,
            compact: true),
      if (chat.loading && chat.conversations.isEmpty)
        const Center(child: CircularProgressIndicator())
      else if (chat.conversations.isEmpty && chat.error == null)
        const PageState(
            variant: PageStateVariant.empty,
            title: 'No conversations yet',
            description: 'Open a mutual match to start a conversation.')
      else
        for (final conversation in chat.conversations)
          Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppSurface(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: AppAvatar(
                      name: conversation.name, imageUrl: conversation.avatar),
                  title: Text(conversation.name,
                      style: TextStyle(
                          fontWeight: conversation.isRead
                              ? FontWeight.w500
                              : FontWeight.bold)),
                  subtitle: Text(conversation.preview,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (chat.online.contains(conversation.id))
                          Text(context.tr('Online')),
                        if (!conversation.isRead)
                          const Icon(Icons.mark_chat_unread_outlined, size: 18),
                      ]),
                  onTap: () => context.router
                      .push(ConversationRoute(conversation: conversation)),
                ),
              )),
    ]);
  }
}
