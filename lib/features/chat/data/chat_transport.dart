import 'package:apsaratalent_mobile/core/network/generated/gateway_api.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import '../domain/chat_models.dart';

abstract class ChatTransport {
  Stream<ChatEvent> get events;
  bool get connected;
  Future<void> connect();
  Future<dynamic> request(String event, [dynamic data]);
  void emit(String event, dynamic data);
  void dispose();
}

/// Owns one socket per signed-in account. Never buffers writes across reconnects:
/// a timed-out message may already be persisted and must not be sent twice.
class SocketChatTransport implements ChatTransport {
  SocketChatTransport(this.api, this.session);

  /// Every event the gateway pushes that this app acts on, spelt exactly as
  /// the gateway emits it. A name that differs by a word is never delivered:
  /// this list once said `unmatched` while the gateway sends `unmatchUpdate`.
  static const serverEvents = [
    'newMessage',
    'messageRead',
    'userTyping',
    'userStatus',
    'messageReaction',
    'messageEdited',
    'messageDeleted',
    'incomingCall',
    'callAnswered',
    'remoteIceCandidate',
    'callDeclined',
    'callEnded',
    ...realtimeRefreshEvents,
  ];

  final ApiClient api;
  final SessionStore session;
  final _events = StreamController<ChatEvent>.broadcast();
  final _pending = <Completer<dynamic>>{};
  io.Socket? _socket;
  Timer? _retry;
  bool _disposed = false, _connecting = false;
  int _attempt = 0;
  @override
  Stream<ChatEvent> get events => _events.stream;
  @override
  bool get connected => _socket?.connected ?? false;

  @override
  Future<void> connect() async {
    if (_disposed || _connecting || connected) return;
    _connecting = true;
    _retry?.cancel();
    try {
      // The HTTP client renews an expired token before it enters the handshake.
      await api.get('/user/current-user');
      if (_disposed || session.accessToken == null) return;
      _socket?.dispose();
      final origin = Uri.parse(api.dio.options.baseUrl).origin;
      final socket = io.io(
          '$origin/chat',
          io.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .disableReconnection()
              .enableForceNew()
              .setAuth({'token': session.accessToken})
              .build());
      _socket = socket;
      socket.onConnect((_) {
        _attempt = 0;
        _events.add(const ChatEvent('connected'));
      });
      socket.onDisconnect((_) {
        _failPending(
            'Connection lost. Check the conversation before retrying.');
        _events.add(const ChatEvent('disconnected'));
        _scheduleRetry();
      });
      socket.onConnectError((_) {
        _events.add(const ChatEvent(
            'connectionError', 'Could not connect to messages.'));
        _scheduleRetry();
      });
      socket.on('error', (data) {
        final message =
            '${chatMap(data)['message'] ?? 'Messaging request failed.'}';
        _failPending(message);
        _events.add(ChatEvent('error', message));
      });
      for (final event in serverEvents) {
        socket.on(event, (data) => _events.add(ChatEvent(event, data)));
      }
      socket.connect();
    } catch (_) {
      if (!_disposed) {
        _events.add(const ChatEvent(
            'connectionError', 'Could not connect to messages.'));
        _scheduleRetry();
      }
    } finally {
      _connecting = false;
    }
  }

  void _scheduleRetry() {
    if (_disposed || _retry?.isActive == true) return;
    final seconds = [1, 2, 4, 8, 15, 30][_attempt.clamp(0, 5)];
    _attempt++;
    _retry = Timer(Duration(seconds: seconds), connect);
  }

  @override
  Future<dynamic> request(String event, [dynamic data]) async {
    if (!connected) {
      throw ApiException(
        message: 'Messages are reconnecting. Please try again.',
      );
    }
    final completer = Completer<dynamic>();
    _pending.add(completer);
    final timeout = Timer(const Duration(seconds: 15), () {
      if (!completer.isCompleted) {
        completer.completeError(
          ApiException(
            message:
                'No confirmation received. Check the conversation before retrying.',
          ),
        );
      }
    });
    try {
      _socket!.emitWithAck(event, data, ack: (dynamic result) {
        if (completer.isCompleted) return;
        if (result is Map &&
            (result['success'] == false || result['status'] == 'error')) {
          completer.completeError(ApiException(
              message: '${result['message'] ?? 'Request rejected.'}'));
        } else {
          completer.complete(result);
        }
      });
      return await completer.future;
    } finally {
      timeout.cancel();
      _pending.remove(completer);
    }
  }

  @override
  void emit(String event, dynamic data) {
    if (connected) _socket!.emit(event, data);
  }

  void _failPending(String message) {
    for (final pending in _pending.toList()) {
      if (!pending.isCompleted) {
        pending.completeError(ApiException(message: message));
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.cancel();
    _failPending('Session ended.');
    _socket?.dispose();
    _events.close();
  }
}
