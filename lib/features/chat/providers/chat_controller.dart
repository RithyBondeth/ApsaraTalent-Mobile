import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import '../data/chat_repository.dart';
import '../data/chat_transport.dart';
import '../domain/chat_models.dart';

final chatRepositoryProvider =
    Provider((ref) => ChatRepository(ref.watch(apiClientProvider)));
final chatTransportProvider = Provider<ChatTransport>((ref) {
  ref.watch(authSessionProvider.select((s) => s.value?.user?.id));
  final transport = SocketChatTransport(
      ref.watch(apiClientProvider), ref.watch(sessionStoreProvider));
  ref.onDispose(transport.dispose);
  return transport;
});
final chatControllerProvider = ChangeNotifierProvider<ChatController>((ref) {
  final id =
      ref.watch(authSessionProvider.select((s) => s.value?.user?.id)) ?? '';
  final controller = ChatController(
      ref.watch(chatTransportProvider), ref.watch(chatRepositoryProvider), id);
  if (id.isNotEmpty) Future.microtask(controller.start);
  return controller;
});

class ChatController extends ChangeNotifier {
  ChatController(this.transport, this.repository, this.me) {
    _subscription = transport.events.listen(_onEvent);
  }
  final ChatTransport transport;
  final ChatRepository repository;
  final String me;
  late final StreamSubscription<ChatEvent> _subscription;
  bool _disposed = false,
      loading = false,
      historyLoading = false,
      sending = false;
  bool historyLimited = false;
  String? error;
  List<Conversation> conversations = [];
  List<ChatMessage> messages = [];
  Conversation? active;
  int unread = 0, _historyGeneration = 0, _recentGeneration = 0;
  final online = <String>{};
  final typing = <String>{};
  final _typingTimers = <String, Timer>{};
  final _reading = <String>{};
  bool get connected => transport.connected;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> start() async {
    if (_disposed) return;
    unawaited(refresh());
    await transport.connect();
  }

  Future<void> refresh() async {
    final generation = ++_recentGeneration;
    loading = true;
    error = null;
    _notify();
    try {
      final result = await repository.recent();
      if (_disposed || generation != _recentGeneration) return;
      conversations = result;
      if (connected) {
        final counts = chatMap(await transport.request('getUnreadCount'));
        if (_disposed || generation != _recentGeneration) return;
        unread = (counts['count'] as num?)?.toInt() ?? 0;
        final statuses = chatMap(await transport.request(
            'getOnlineUsers', conversations.map((c) => c.id).toList()));
        if (_disposed || generation != _recentGeneration) return;
        online
          ..clear()
          ..addAll(
              statuses.entries.where((e) => e.value == true).map((e) => e.key));
      }
    } catch (e) {
      if (generation == _recentGeneration) error = messageFor(e);
    } finally {
      if (generation == _recentGeneration) {
        loading = false;
        _notify();
      }
    }
  }

  Future<Conversation> initiate(String accountOrProfileId) async {
    final conversation = await repository.initiate(accountOrProfileId);
    if (_disposed) throw ApiException(message: 'Session ended.');
    unawaited(refresh());
    return conversation;
  }

  Future<void> open(Conversation conversation) async {
    active = conversation;
    messages = [];
    await loadHistory();
  }

  void closeConversation() {
    if (active != null) setTyping(false);
    active = null;
    messages = [];
    _historyGeneration++;
    historyLoading = false;
    _notify();
  }

  Future<void> loadHistory() async {
    final partner = active;
    if (partner == null) return;
    final generation = ++_historyGeneration;
    historyLoading = true;
    historyLimited = false;
    error = null;
    _notify();
    try {
      // The API pages oldest-first. Follow pages to reach the current messages;
      // never silently show the first 50 messages as if they were the latest.
      for (var offset = 0; offset <= 10000; offset += 100) {
        final data = chatMap(await transport.request('getChatHistory', {
          'partnerId': partner.id,
          'limit': 100,
          'offset': offset,
        }));
        if (_disposed || generation != _historyGeneration) return;
        if (data['messages'] is! List || data['partnerProfile'] == null) {
          throw ApiException(
              message: 'Could not load this conversation. Try again.');
        }
        final page =
            (data['messages'] as List).map(ChatMessage.fromJson).toList();
        _merge(page);
        if (page.length < 100) break;
        if (offset == 10000) historyLimited = true;
      }
      if (generation == _historyGeneration) await markVisibleRead();
    } catch (e) {
      if (generation == _historyGeneration) error = messageFor(e);
    } finally {
      if (generation == _historyGeneration) {
        historyLoading = false;
        _notify();
      }
    }
  }

  void _merge(Iterable<ChatMessage> incoming) {
    final byId = {for (final m in messages) m.id: m};
    for (final m in incoming) {
      if (m.id.isNotEmpty) byId[m.id] = m;
    }
    messages = byId.values.toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    _notify();
  }

  Future<void> send(String content,
      {ChatAttachment? attachment, String? replyToId}) async {
    final partner = active;
    if (partner == null || sending) return;
    if (content.trim().isEmpty && attachment == null) return;
    if (content.trim().length > 5000) {
      throw ApiException(
          message: 'Messages can contain up to 5,000 characters.');
    }
    sending = true;
    error = null;
    _notify();
    try {
      final response = chatMap(await transport.request('sendMessage', {
        'receiverId': partner.id,
        'content': content.trim(),
        'type': attachment?.type ?? 'text',
        if (replyToId != null) 'replyToId': replyToId,
        if (attachment != null) ...{
          'attachment': attachment.url,
          'attachmentFilename': attachment.filename
        },
      }));
      if (response['status'] != 'sent' || response['message'] is! Map) {
        throw ApiException(message: 'Message was not confirmed.');
      }
      if (!_disposed && active?.id == partner.id) {
        _merge([ChatMessage.fromJson(response['message'])]);
      }
      unawaited(refresh());
    } catch (e) {
      error = messageFor(e);
      rethrow;
    } finally {
      sending = false;
      _notify();
    }
  }

  Future<void> edit(ChatMessage message, String text) async {
    if (text.trim().isEmpty || text.trim().length > 5000) {
      throw ApiException(message: 'Enter between 1 and 5,000 characters.');
    }
    await transport.request('editMessage', {
      'messageId': message.id,
      'receiverId': message.receiverId,
      'newContent': text.trim()
    });
    _update(
        message.id, (m) => m.copyWith(content: text.trim(), isEdited: true));
  }

  Future<void> remove(ChatMessage message) async {
    await transport.request('deleteMessage',
        {'messageId': message.id, 'receiverId': message.receiverId});
    _update(message.id, (m) => m.copyWith(isDeleted: true));
  }

  Future<void> react(ChatMessage message, String? emoji) async {
    final partner =
        message.senderId == me ? message.receiverId : message.senderId;
    final data = chatMap(await transport.request('react',
        {'messageId': message.id, 'receiverId': partner, 'emoji': emoji}));
    _update(
        message.id,
        (m) => m.copyWith(
            reactions:
                chatMap(data['reactions']).map((k, v) => MapEntry(k, '$v'))));
  }

  void setTyping(bool value) {
    if (active != null) {
      transport.emit('typing', {'receiverId': active!.id, 'isTyping': value});
    }
  }

  Future<void> markVisibleRead() async {
    if (!connected || active == null) return;
    for (final message
        in messages.where((m) => m.receiverId == me && !m.isRead).toList()) {
      if (!_reading.add(message.id)) continue;
      try {
        await transport.request('markAsRead',
            {'messageId': message.id, 'senderId': message.senderId});
        if (_disposed) return;
        _update(message.id, (m) => m.copyWith(isRead: true));
        unread = (unread - 1).clamp(0, 1 << 30);
      } catch (_) {
        break;
      } finally {
        _reading.remove(message.id);
      }
      if (active == null) break;
    }
    _notify();
  }

  void _update(String id, ChatMessage Function(ChatMessage) change) {
    messages = [
      for (final m in messages)
        if (m.id == id) change(m) else m
    ];
    _notify();
  }

  void _onEvent(ChatEvent event) {
    if (_disposed) return;
    final data = chatMap(event.data);
    switch (event.name) {
      case 'connected':
        error = null;
        unawaited(refresh());
        if (active != null) unawaited(loadHistory());
      case 'disconnected':
        online.clear();
        typing.clear();
      case 'connectionError':
      case 'error':
        error = '${event.data}';
      case 'newMessage':
        final m = ChatMessage.fromJson(data);
        final partner = m.senderId == me ? m.receiverId : m.senderId;
        if (active?.id == partner) {
          _merge([m]);
          unawaited(markVisibleRead());
        }
        unawaited(refresh());
      case 'messageRead':
        _update('${data['messageId']}', (m) => m.copyWith(isRead: true));
      case 'messageEdited':
        _update(
            '${data['messageId']}',
            (m) =>
                m.copyWith(content: '${data['newContent']}', isEdited: true));
      case 'messageDeleted':
        _update('${data['messageId']}', (m) => m.copyWith(isDeleted: true));
      case 'messageReaction':
        _update(
            '${data['messageId']}',
            (m) => m.copyWith(
                reactions: chatMap(data['reactions'])
                    .map((k, v) => MapEntry(k, '$v'))));
      case 'userStatus':
        final id = '${data['userId']}';
        data['status'] == 'online' ? online.add(id) : online.remove(id);
      case 'userTyping':
        final id = '${data['userId']}';
        _typingTimers.remove(id)?.cancel();
        if (data['isTyping'] == true) {
          typing.add(id);
          _typingTimers[id] = Timer(const Duration(seconds: 5), () {
            typing.remove(id);
            _notify();
          });
        } else {
          typing.remove(id);
        }
    }
    _notify();
  }

  static String messageFor(Object e) =>
      e is ApiException ? e.message : 'Something went wrong. Please try again.';
  @override
  void dispose() {
    _disposed = true;
    _historyGeneration++;
    _recentGeneration++;
    _subscription.cancel();
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
