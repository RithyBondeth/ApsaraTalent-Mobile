import 'generated/gateway_api.dart';
import 'dart:async';
import 'package:apsaratalent_mobile/features/chat/providers/chat_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/match/providers/match_notifier.dart';
import 'package:apsaratalent_mobile/features/application/providers/employer_workflow_provider.dart';
import 'package:apsaratalent_mobile/features/application/providers/application_notifier.dart';
import 'package:apsaratalent_mobile/features/notification/providers/notification_notifier.dart';

/// Server rereads make socket/push duplicates converge instead of adding to
/// counters twice. Invalidation also covers mounted family instances.
void refreshRealtimeData(void Function(ProviderOrFamily) invalidate) {
  for (final provider in <ProviderOrFamily>[
    feedProvider,
    matchesProvider,
    matchCountProvider,
    employeeInterviewsProvider,
    employerInterviewsProvider,
    employerAnalyticsProvider,
    jobPipelineProvider,
    applicationsProvider,
    notificationsProvider
  ]) {
    invalidate(provider);
  }
}

final realtimeRefreshProvider = Provider<void>((ref) {
  Timer? pending;
  final subscription = ref.watch(chatTransportProvider).events.listen((event) {
    if (event.name != 'connected' &&
        !realtimeRefreshEvents.contains(event.name)) {
      return;
    }
    pending?.cancel();
    pending = Timer(const Duration(milliseconds: 150),
        () => refreshRealtimeData(ref.invalidate));
  });
  ref.onDispose(() {
    pending?.cancel();
    subscription.cancel();
  });
});
