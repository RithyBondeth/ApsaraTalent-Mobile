import 'dart:async';

import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/call/data/voice_peer.dart';
import 'package:apsaratalent_mobile/features/call/providers/call_controller.dart';
import 'package:apsaratalent_mobile/features/chat/data/chat_repository.dart';
import 'package:apsaratalent_mobile/features/chat/data/chat_transport.dart';
import 'package:apsaratalent_mobile/features/chat/domain/chat_models.dart';
import 'package:flutter_test/flutter_test.dart';

class _Transport implements ChatTransport {
  final controller = StreamController<ChatEvent>.broadcast();
  final requests = <(String, dynamic)>[];
  final emissions = <(String, dynamic)>[];
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
    return {'success': true};
  }
}

class _Repository extends ChatRepository {
  _Repository()
      : super(ApiClient(
          sessionStore: SessionStore(),
          baseUrl: 'http://localhost:3000',
        ));
  @override
  Future<Conversation> initiate(String id) async =>
      Conversation(id: id, name: 'Partner');
  @override
  Future<List<Map<String, dynamic>>> iceServers() async => [
        {'urls': 'stun:example.test'},
      ];
}

class _Peer implements VoicePeer {
  void Function(Map<String, dynamic>)? onIce;
  void Function(String)? onState;
  bool closed = false;
  @override
  Future<void> initialize(List<Map<String, dynamic>> servers,
      {required void Function(Map<String, dynamic>) onIce,
      required void Function(String) onState}) async {
    this.onIce = onIce;
    this.onState = onState;
  }

  @override
  Future<Map<String, dynamic>> offer() async =>
      {'type': 'offer', 'sdp': 'offer'};
  @override
  Future<Map<String, dynamic>> answer(Map<String, dynamic> offer) async =>
      {'type': 'answer', 'sdp': 'answer'};
  @override
  Future<void> acceptAnswer(Map<String, dynamic> answer) async {}
  @override
  Future<void> addIce(Map<String, dynamic> candidate) async {}
  @override
  void mute(bool value) {}
  @override
  Future<void> speaker(bool value) async {}
  @override
  Future<void> close() async => closed = true;
}

void main() {
  test('outgoing call offers, connects, and closes its peer', () async {
    final transport = _Transport();
    final peer = _Peer();
    final calls = CallController(transport, _Repository(), () => peer);

    await calls.start(const Conversation(id: 'partner', name: 'Partner'));
    expect(calls.phase, CallPhase.calling);
    expect(
        transport.requests.map((request) => request.$1), contains('callOffer'));

    transport.controller.add(ChatEvent('callAnswered', {
      'callId': calls.callId,
      'answer': {'type': 'answer', 'sdp': 'answer'},
    }));
    await Future<void>.delayed(Duration.zero);
    peer.onState?.call('connected');
    expect(calls.phase, CallPhase.connected);

    await calls.end();
    expect(peer.closed, isTrue);
    expect(calls.phase, CallPhase.ended);
    calls.dispose();
    transport.dispose();
  });

  test('incoming call can be declined without opening the microphone',
      () async {
    final transport = _Transport();
    var peersCreated = 0;
    final calls = CallController(
      transport,
      _Repository(),
      () {
        peersCreated++;
        return _Peer();
      },
    );

    transport.controller.add(const ChatEvent('incomingCall', {
      'callId': 'call-1',
      'callerId': 'partner',
      'callerName': 'Partner',
      'offer': {'type': 'offer', 'sdp': 'offer'},
    }));
    await Future<void>.delayed(Duration.zero);
    expect(calls.phase, CallPhase.ringing);

    await calls.decline();
    expect(peersCreated, 0);
    expect(
      transport.emissions.map((emission) => emission.$1),
      contains('callDecline'),
    );
    calls.dispose();
    transport.dispose();
  });
}
