import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Small platform boundary so signaling and lifecycle can be tested without a
/// microphone, emulator, or TURN service.
abstract class VoicePeer {
  Future<void> initialize(
    List<Map<String, dynamic>> servers, {
    required void Function(Map<String, dynamic>) onIce,
    required void Function(String) onState,
  });
  Future<Map<String, dynamic>> offer();
  Future<Map<String, dynamic>> answer(Map<String, dynamic> offer);
  Future<void> acceptAnswer(Map<String, dynamic> answer);
  Future<void> addIce(Map<String, dynamic> candidate);
  void mute(bool value);
  Future<void> speaker(bool value);
  Future<void> close();
}

class WebRtcVoicePeer implements VoicePeer {
  RTCPeerConnection? _peer;
  MediaStream? _stream;
  bool _closed = false, _remoteReady = false;
  final _ice = <Map<String, dynamic>>[];
  @override
  Future<void> initialize(
    List<Map<String, dynamic>> servers, {
    required void Function(Map<String, dynamic>) onIce,
    required void Function(String) onState,
  }) async {
    final stream = await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': false});
    if (_closed) {
      for (final t in stream.getTracks()) {
        await t.stop();
      }
      await stream.dispose();
      return;
    }
    _stream = stream;
    final peer = await createPeerConnection(
        {'iceServers': servers, 'sdpSemantics': 'unified-plan'});
    if (_closed) {
      await peer.close();
      await peer.dispose();
      return;
    }
    _peer = peer;
    peer.onIceCandidate = (c) {
      if (!_closed && c.candidate?.isNotEmpty == true) onIce(c.toMap());
    };
    peer.onConnectionState = (state) {
      if (_closed) return;
      onState(switch (state) {
        RTCPeerConnectionState.RTCPeerConnectionStateConnected => 'connected',
        RTCPeerConnectionState.RTCPeerConnectionStateFailed => 'failed',
        RTCPeerConnectionState.RTCPeerConnectionStateDisconnected =>
          'disconnected',
        RTCPeerConnectionState.RTCPeerConnectionStateClosed => 'closed',
        _ => 'connecting',
      });
    };
    for (final track in stream.getAudioTracks()) {
      await peer.addTrack(track, stream);
    }
    await Helper.setSpeakerphoneOn(false);
  }

  @override
  Future<Map<String, dynamic>> offer() async {
    final description = await _peer!.createOffer({'offerToReceiveAudio': true});
    await _peer!.setLocalDescription(description);
    return description.toMap();
  }

  Future<void> _setRemote(Map<String, dynamic> description) async {
    await _peer!.setRemoteDescription(
        RTCSessionDescription(description['sdp'], description['type']));
    _remoteReady = true;
    final queued = _ice.toList();
    _ice.clear();
    for (final candidate in queued) {
      await addIce(candidate);
    }
  }

  @override
  Future<Map<String, dynamic>> answer(Map<String, dynamic> offer) async {
    await _setRemote(offer);
    final description =
        await _peer!.createAnswer({'offerToReceiveAudio': true});
    await _peer!.setLocalDescription(description);
    return description.toMap();
  }

  @override
  Future<void> acceptAnswer(Map<String, dynamic> answer) => _setRemote(answer);
  @override
  Future<void> addIce(Map<String, dynamic> candidate) async {
    if (_closed) return;
    if (!_remoteReady) {
      _ice.add(candidate);
      return;
    }
    await _peer!.addCandidate(RTCIceCandidate(candidate['candidate'],
        candidate['sdpMid'], (candidate['sdpMLineIndex'] as num?)?.toInt()));
  }

  @override
  void mute(bool value) {
    for (final track in _stream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !value;
    }
  }

  @override
  Future<void> speaker(bool value) => Helper.setSpeakerphoneOn(value);
  @override
  Future<void> close() async {
    _closed = true;
    _ice.clear();
    final stream = _stream;
    _stream = null;
    final peer = _peer;
    _peer = null;
    for (final track in stream?.getTracks() ?? <MediaStreamTrack>[]) {
      await track.stop();
    }
    await stream?.dispose();
    await peer?.close();
    await peer?.dispose();
  }
}
