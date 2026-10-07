import 'package:apsaratalent_mobile/features/application/providers/employer_workflow_provider.dart';
import 'package:apsaratalent_mobile/features/chat/providers/chat_controller.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/match/providers/match_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeps matches, the match badge and interviews current while the app is
/// open, from the gateway's socket pushes. None of them carries a payload, so
/// each one just refetches what it affects. Refetching a provider nobody is
/// showing costs nothing.
///
/// - `unmatchUpdate` goes to both people. Unmatching deletes the match row,
///   which holds both sides' likes, and the interviews between them, so the
///   counterpart is a feed card again.
/// - `badgeIncrement` follows a like aimed at this account, or an interview.
/// - `interviewUpdate` follows an interview being scheduled or changed.
///
/// Watched by the signed-in realtime host, so it lives as long as the socket.
final matchRealtimeSyncProvider = Provider<void>((ref) {
  void refreshInterviews() => ref
    ..invalidate(employerInterviewsProvider)
    ..invalidate(employeeInterviewsProvider);

  final subscription = ref.watch(chatTransportProvider).events.listen((event) {
    switch (event.name) {
      case 'unmatchUpdate':
        ref
          ..invalidate(matchesProvider)
          ..invalidate(matchCountProvider)
          ..invalidate(feedProvider);
        refreshInterviews();
      case 'badgeIncrement':
        ref
          ..invalidate(matchesProvider)
          ..invalidate(matchCountProvider);
      case 'interviewUpdate':
        refreshInterviews();
    }
  });
  ref.onDispose(subscription.cancel);
});
