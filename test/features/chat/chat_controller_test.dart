import 'dart:async';

import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/chat/data/chat_repository.dart';
import 'package:apsaratalent_mobile/features/chat/data/chat_transport.dart';
import 'package:apsaratalent_mobile/features/chat/domain/chat_models.dart';
import 'package:apsaratalent_mobile/features/chat/providers/chat_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _Transport implements ChatTransport {
  final controller = StreamController<ChatEvent>.broadcast();
  final requests = <(String, dynamic)>[];
  final emissions = <(String, dynamic)>[];
  final replies = <String, dynamic>{};

  @override
  bool connected = true;

  @override
  Stream<ChatEvent> get events => controller.stream;

  @override
  Future<void> connect() async {}

  @override
  void dispose() => controller.close();

  @override
  void emit(String event, dynamic data) => emissions.add((event, data));

  @override
  Future<dynamic> request(String event, [dynamic data]) async {
    requests.add((event, data));
    return replies[event];
  }
}

class _Repository extends ChatRepository {
  _Repository()
      : super(ApiClient(
          sessionStore: SessionStore(),
          baseUrl: 'http://localhost:3000',
        ));

  @override
  Future<List<Conversation>> recent() async => const [
        Conversation(id: 'partner', name: 'Partner', preview: 'Hello'),
      ];
}

void main() {
  test('loads conversations, history, and marks received messages read',
      () async {
    final transport = _Transport();
    transport.replies
      ..['getUnreadCount'] = {'count': 1}
      ..['getOnlineUsers'] = {'partner': true}
      ..['getChatHistory'] = {
        'partnerId': 'partner',
        'partnerProfile': {'id': 'partner'},
        'messages': [
          {
            'id': 'message-1',
            'senderId': 'partner',
            'receiverId': 'me',
            'content': 'Hello',
            'sentAt': '2026-01-01T00:00:00Z',
            'isRead': false,
          }
        ],
      }
      ..['markAsRead'] = {'success': true};
    final chat = ChatController(transport, _Repository(), 'me');

    await chat.refresh();
    await chat.open(chat.conversations.single);

    expect(chat.online, contains('partner'));
    expect(chat.messages.single.isRead, isTrue);
    expect(chat.unread, 0);
    expect(
      transport.requests.where((request) => request.$1 == 'markAsRead'),
      hasLength(1),
    );
    chat.dispose();
    transport.dispose();
  });

  test('adds a confirmed send once and applies realtime edits', () async {
    final transport = _Transport();
    transport.replies
      ..['getChatHistory'] = {
        'partnerId': 'partner',
        'partnerProfile': {'id': 'partner'},
        'messages': <Object>[],
      }
      ..['sendMessage'] = {
        'status': 'sent',
        'message': {
          'id': 'message-1',
          'senderId': 'me',
          'receiverId': 'partner',
          'content': 'Hello',
          'sentAt': '2026-01-01T00:00:00Z',
        },
      };
    final chat = ChatController(transport, _Repository(), 'me');
    await chat.open(const Conversation(id: 'partner', name: 'Partner'));

    await chat.send('  Hello  ');
    transport.controller.add(const ChatEvent('messageEdited', {
      'messageId': 'message-1',
      'newContent': 'Updated',
    }));
    await Future<void>.delayed(Duration.zero);

    expect(chat.messages, hasLength(1));
    expect(chat.messages.single.content, 'Updated');
    expect(chat.messages.single.isEdited, isTrue);
    chat.dispose();
    transport.dispose();
  });

  test('only authorizes gateway attachment paths', () {
    expect(
      ChatRepository.attachmentPath(
        'https://api.example/chat/attachment/2026-01-01/file.pdf',
      ),
      '/chat/attachment/2026-01-01/file.pdf',
    );
    expect(
      () => ChatRepository.attachmentPath('https://evil.example/file.pdf'),
      throwsA(isA<Exception>()),
    );
  });
}
