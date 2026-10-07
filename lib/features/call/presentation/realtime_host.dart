import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/chat/providers/chat_controller.dart';
import 'package:apsaratalent_mobile/features/match/providers/match_realtime_provider.dart';
import '../providers/call_controller.dart';

/// Above the router so incoming calls are visible on any signed-in page.
class RealtimeHost extends ConsumerWidget {
  const RealtimeHost({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider.select((s) => s.value?.user));
    if (user == null) return child;
    return _SignedInRealtime(key: ValueKey(user.id), child: child);
  }
}

class _SignedInRealtime extends ConsumerStatefulWidget {
  const _SignedInRealtime({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<_SignedInRealtime> createState() => _RealtimeState();
}

class _RealtimeState extends ConsumerState<_SignedInRealtime>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(chatTransportProvider).connect();
      ref.read(chatControllerProvider).refresh();
    }
    // Foreground calling only. Do not leave the microphone running under an
    // OS-suspended app without a foreground service / CallKit integration.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ref
          .read(callControllerProvider)
          .end(message: 'Call ended when the app moved to the background.');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(chatControllerProvider);
    ref.watch(matchRealtimeSyncProvider);
    final call = ref.watch(callControllerProvider);
    return Stack(children: [
      widget.child,
      if (call.phase != CallPhase.idle) ...[
        const Positioned.fill(
            child: ModalBarrier(dismissible: false, color: Colors.black54)),
        Positioned.fill(
            child: SafeArea(
                child: Center(
                    child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.phone_in_talk_outlined, size: 48),
                        const SizedBox(height: 16),
                        Text(call.partnerName,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(_label(call), textAlign: TextAlign.center),
                        if (call.error != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(call.error!,
                                  textAlign: TextAlign.center)),
                        const SizedBox(height: 24),
                        if (call.phase == CallPhase.ringing)
                          Wrap(spacing: 16, children: [
                            OutlinedButton.icon(
                                onPressed: call.decline,
                                icon: const Icon(Icons.call_end),
                                label: const Text('Decline')),
                            FilledButton.icon(
                                onPressed: call.answer,
                                icon: const Icon(Icons.call),
                                label: const Text('Answer')),
                          ])
                        else if (call.phase == CallPhase.ended)
                          FilledButton(
                              onPressed: call.dismiss,
                              child: const Text('Close'))
                        else ...[
                          Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              children: [
                                IconButton.filledTonal(
                                    tooltip: call.muted ? 'Unmute' : 'Mute',
                                    onPressed: call.toggleMute,
                                    icon: Icon(call.muted
                                        ? Icons.mic_off
                                        : Icons.mic)),
                                IconButton.filledTonal(
                                    tooltip: call.speakerOn
                                        ? 'Use earpiece'
                                        : 'Use speaker',
                                    onPressed: call.toggleSpeaker,
                                    icon: Icon(call.speakerOn
                                        ? Icons.volume_up
                                        : Icons.hearing)),
                                IconButton.filled(
                                    tooltip: 'End call',
                                    style: IconButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .error),
                                    onPressed: () => call.end(),
                                    icon: const Icon(Icons.call_end)),
                              ]),
                        ],
                      ]),
                    )),
              )),
        )))),
      ],
    ]);
  }

  String _label(CallController call) => switch (call.phase) {
        CallPhase.idle => '',
        CallPhase.ringing => 'Incoming voice call',
        CallPhase.calling => 'Calling…',
        CallPhase.connecting => 'Connecting audio…',
        CallPhase.connected =>
          '${call.duration.inMinutes.toString().padLeft(2, '0')}:${(call.duration.inSeconds % 60).toString().padLeft(2, '0')}',
        CallPhase.ended => switch (call.endReason) {
            'declined' => 'Call declined',
            'missed' => 'No answer',
            _ => 'Call ended'
          },
      };
}
