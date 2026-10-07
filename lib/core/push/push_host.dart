import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/chat/providers/chat_controller.dart';
import 'package:apsaratalent_mobile/core/network/realtime_refresh.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';
import 'push_bootstrap.dart';
import 'push_providers.dart';

class PushHost extends ConsumerWidget {
  const PushHost({super.key, required this.router, required this.child});

  final AppRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(
      authSessionProvider.select((state) => state.value?.user?.id),
    );
    if (userId == null || !PushBootstrap.available) return child;
    return _SignedInPushHost(
      key: ValueKey(userId),
      router: router,
      child: child,
    );
  }
}

class _SignedInPushHost extends ConsumerStatefulWidget {
  const _SignedInPushHost({
    super.key,
    required this.router,
    required this.child,
  });

  final AppRouter router;
  final Widget child;

  @override
  ConsumerState<_SignedInPushHost> createState() => _SignedInPushHostState();
}

class _SignedInPushHostState extends ConsumerState<_SignedInPushHost>
    with WidgetsBindingObserver {
  StreamSubscription<RemoteMessage>? _foreground;
  StreamSubscription<RemoteMessage>? _opened;
  StreamSubscription<String>? _tokens;
  final _handled = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final tokens = ref.read(pushTokenServiceProvider);
    unawaited(tokens.register());
    _tokens = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      unawaited(tokens.registerToken(token));
    });
    _foreground = FirebaseMessaging.onMessage.listen(_received);
    _opened = FirebaseMessaging.onMessageOpenedApp.listen(_open);
    unawaited(_initialMessage());
  }

  Future<void> _initialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_open(message));
    });
  }

  void _received(RemoteMessage message) {
    _refresh(message.data['type']);
  }

  void _refresh(String? type) {
    refreshRealtimeData(ref.invalidate);
    if (type == 'chat') unawaited(ref.read(chatControllerProvider).refresh());
  }

  Future<void> _open(RemoteMessage message) async {
    final key = message.messageId ??
        '${message.data['messageId']}:${message.data['senderId']}';
    if (!_handled.add(key)) return;
    _refresh(message.data['type']);

    if (message.data['type'] == 'chat') {
      final senderId = message.data['senderId'];
      if (senderId != null && senderId.isNotEmpty) {
        try {
          final conversation =
              await ref.read(chatControllerProvider).initiate(senderId);
          if (mounted) {
            await widget.router.push(
              ConversationRoute(conversation: conversation),
            );
          }
          return;
        } catch (_) {
          // The notification feed remains a useful fallback if the match was
          // removed or the conversation cannot be loaded yet.
        }
      }
    }
    if (!mounted) return;
    final type = message.data['type'];
    switch (type) {
      case 'match':
      case 'like':
        await widget.router.push(const MatchRoute());
      case 'application':
      case 'offer':
        final jobId = message.data['jobId'];
        await widget.router.push(jobId == null || jobId.isEmpty
            ? const ApplicationRoute()
            : JobDetailRoute(jobId: jobId));
      case 'interview':
        final role = ref.read(authSessionProvider).value?.user?.role;
        await widget.router.push(role == EUserRole.employee
            ? const InterviewScheduleRoute()
            : const ApplicationRoute());
      case 'call':
        await widget.router.push(const ChatRoute());
      default:
        await widget.router.push(const NotificationRoute());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(pushTokenServiceProvider).register());
      _refresh(null);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _foreground?.cancel();
    _opened?.cancel();
    _tokens?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
