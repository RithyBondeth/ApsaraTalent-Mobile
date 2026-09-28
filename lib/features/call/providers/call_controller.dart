import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/chat/data/chat_repository.dart';
import 'package:apsaratalent_mobile/features/chat/data/chat_transport.dart';
import 'package:apsaratalent_mobile/features/chat/domain/chat_models.dart';
import 'package:apsaratalent_mobile/features/chat/providers/chat_controller.dart';
import '../data/voice_peer.dart';

final callControllerProvider = ChangeNotifierProvider((ref) => CallController(
    ref.watch(chatTransportProvider),
    ref.watch(chatRepositoryProvider),
    WebRtcVoicePeer.new));

enum CallPhase { idle, ringing, calling, connecting, connected, ended }

class CallController extends ChangeNotifier {
  CallController(
    this.transport,
    this.repository,
    this.createPeer, {
    this.ringTimeout = const Duration(seconds: 45),
    this.connectTimeout = const Duration(seconds: 30),
  }) {
    _subscription = transport.events.listen((e) {
      unawaited(_event(e));
    });
  }
  final ChatTransport transport;
  final ChatRepository repository;
  final VoicePeer Function() createPeer;
  final Duration ringTimeout, connectTimeout;
  late final StreamSubscription<ChatEvent> _subscription;
  VoicePeer? _peer;
  Timer? _timeout, _ticker, _disconnectTimer;
  bool _disposed = false, muted = false, speakerOn = false, _signalSent = false;
  int _generation = 0;
  final _localIce = <Map<String, dynamic>>[];
  final _remoteIce = <Map<String, dynamic>>[];
  Map<String, dynamic>? _offer;
  CallPhase phase = CallPhase.idle;
  String? callId, partnerId, error, endReason;
  String partnerName = '';
  DateTime? startedAt;
  bool get active => phase != CallPhase.idle && phase != CallPhase.ended;
  Duration get duration =>
      startedAt == null ? Duration.zero : DateTime.now().difference(startedAt!);
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  bool _current(int generation) =>
      !_disposed && generation == _generation && active;

  Future<void> start(Conversation partner) async {
    if (active) return;
    if (!transport.connected) {
      throw ApiException(
          message: 'Wait for messages to reconnect before calling.');
    }
    // Reuse the server's match/block check before requesting microphone access.
    await repository.initiate(partner.id);
    if (_disposed || active) return;
    _begin(const Uuid().v4(), partner.id, partner.name, CallPhase.calling);
    final generation = _generation;
    try {
      await _initialize(generation);
      if (!_current(generation)) return;
      final offer = await _peer!.offer();
      if (!_current(generation)) return;
      await transport.request('callOffer',
          {'callId': callId, 'receiverId': partnerId, 'offer': offer});
      if (!_current(generation)) return;
      _signalSent = true;
      _flushLocalIce();
    } catch (e) {
      if (_current(generation)) await _fail(e);
    }
  }

  void _begin(String id, String partner, String name, CallPhase next) {
    _generation++;
    _timeout?.cancel();
    callId = id;
    partnerId = partner;
    partnerName = name;
    phase = next;
    error = null;
    endReason = null;
    startedAt = null;
    muted = false;
    speakerOn = false;
    _signalSent = false;
    _localIce.clear();
    _remoteIce.clear();
    _timeout = Timer(ringTimeout, () => end(reason: 'missed'));
    _notify();
  }

  Future<void> _initialize(int generation) async {
    final servers = await repository.iceServers();
    if (!_current(generation)) return;
    final peer = createPeer();
    _peer = peer;
    await peer.initialize(servers, onIce: (candidate) {
      if (!_current(generation)) return;
      _localIce.add(candidate);
      _flushLocalIce();
    }, onState: (state) {
      if (!_current(generation)) return;
      if (state == 'connected') {
        _timeout?.cancel();
        _disconnectTimer?.cancel();
        phase = CallPhase.connected;
        startedAt ??= DateTime.now();
        _ticker ??=
            Timer.periodic(const Duration(seconds: 1), (_) => _notify());
        _notify();
      } else if (state == 'failed' || state == 'closed') {
        unawaited(end(reason: 'error', message: 'The call connection failed.'));
      } else if (state == 'disconnected') {
        _disconnectTimer?.cancel();
        _disconnectTimer = Timer(
            const Duration(seconds: 8),
            () =>
                end(reason: 'error', message: 'The call connection was lost.'));
      }
    });
    if (!_current(generation)) {
      await peer.close();
      return;
    }
    for (final candidate in _remoteIce.toList()) {
      await peer.addIce(candidate);
    }
    _remoteIce.clear();
  }

  void _flushLocalIce() {
    if (!_signalSent) return;
    for (final candidate in _localIce) {
      transport.emit('iceCandidate', {
        'callId': callId,
        'targetUserId': partnerId,
        'candidate': candidate
      });
    }
    _localIce.clear();
  }

  Future<void> answer() async {
    if (phase != CallPhase.ringing || _offer == null) return;
    phase = CallPhase.connecting;
    _armConnect();
    _notify();
    final generation = _generation;
    try {
      await repository.initiate(partnerId!);
      if (!_current(generation)) return;
      await _initialize(generation);
      if (!_current(generation)) return;
      final answer = await _peer!.answer(_offer!);
      if (!_current(generation)) return;
      await transport.request('callAnswer',
          {'callId': callId, 'callerId': partnerId, 'answer': answer});
      if (!_current(generation)) return;
      _signalSent = true;
      _flushLocalIce();
    } catch (e) {
      if (_current(generation)) await _fail(e);
    }
  }

  void _armConnect() {
    _timeout?.cancel();
    _timeout = Timer(connectTimeout,
        () => end(reason: 'error', message: 'The call could not connect.'));
  }

  Future<void> decline() async {
    if (phase != CallPhase.ringing) return;
    transport.emit('callDecline', {'callId': callId, 'callerId': partnerId});
    await end(reason: 'declined', signal: false);
  }

  Future<void> end(
      {String reason = 'ended', String? message, bool signal = true}) async {
    if (!active) return;
    if (signal) {
      transport.emit('callEnd',
          {'callId': callId, 'targetUserId': partnerId, 'reason': reason});
    }
    _generation++;
    phase = CallPhase.ended;
    error = message;
    endReason = reason;
    _timeout?.cancel();
    _ticker?.cancel();
    _ticker = null;
    _disconnectTimer?.cancel();
    _offer = null;
    _localIce.clear();
    _remoteIce.clear();
    final peer = _peer;
    _peer = null;
    _notify();
    try {
      await peer?.close();
    } catch (_) {/* Already closed by platform. */}
  }

  Future<void> _fail(Object e) => end(
      reason: 'error',
      message: e is ApiException
          ? e.message
          : 'Could not start audio. Check microphone permission and try again.');
  void dismiss() {
    if (!active) {
      phase = CallPhase.idle;
      error = null;
      _notify();
    }
  }

  void toggleMute() {
    if (_peer == null) return;
    muted = !muted;
    _peer!.mute(muted);
    _notify();
  }

  Future<void> toggleSpeaker() async {
    try {
      await _peer?.speaker(!speakerOn);
      speakerOn = !speakerOn;
      _notify();
    } catch (_) {
      error = 'Could not switch the audio output.';
      _notify();
    }
  }

  Future<void> _event(ChatEvent event) async {
    if (_disposed) return;
    final data = chatMap(event.data);
    if (event.name == 'disconnected' && active) {
      await end(
          reason: 'error',
          message: 'Messaging disconnected. Please call again.',
          signal: false);
      return;
    }
    if (event.name == 'incomingCall') {
      final offer = chatMap(data['offer']);
      final id = '${data['callId'] ?? ''}',
          caller = '${data['callerId'] ?? ''}';
      if (id.isEmpty ||
          caller.isEmpty ||
          offer['sdp'] is! String ||
          offer['type'] != 'offer') {
        return;
      }
      if (active) {
        if (id != callId) {
          transport.emit('callDecline', {'callId': id, 'callerId': caller});
        }
        return;
      }
      _begin(id, caller, '${data['callerName'] ?? 'Incoming caller'}',
          CallPhase.ringing);
      _offer = offer;
      return;
    }
    if (!active || data['callId'] != callId) return;
    final generation = _generation;
    try {
      switch (event.name) {
        case 'callAnswered':
          if (phase != CallPhase.calling || _peer == null) return;
          phase = CallPhase.connecting;
          _armConnect();
          _notify();
          await _peer!.acceptAnswer(chatMap(data['answer']));
        case 'remoteIceCandidate':
          final candidate = chatMap(data['candidate']);
          if (_peer == null) {
            if (_remoteIce.length < 256) _remoteIce.add(candidate);
          } else {
            await _peer!.addIce(candidate);
          }
        case 'callDeclined':
          await end(reason: 'declined', signal: false);
        case 'callEnded':
          await end(reason: '${data['reason'] ?? 'ended'}', signal: false);
      }
    } catch (e) {
      if (_current(generation)) await _fail(e);
    }
  }

  @override
  void dispose() {
    if (active) {
      transport.emit('callEnd',
          {'callId': callId, 'targetUserId': partnerId, 'reason': 'ended'});
    }
    _disposed = true;
    _generation++;
    _subscription.cancel();
    _timeout?.cancel();
    _ticker?.cancel();
    _disconnectTimer?.cancel();
    final peer = _peer;
    _peer = null;
    if (peer != null) unawaited(peer.close().catchError((Object _) {}));
    super.dispose();
  }
}
