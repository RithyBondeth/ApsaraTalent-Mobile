import 'dart:async';

import 'package:apsaratalent_mobile/features/application/domain/entities/employer_workflow.dart';
import 'package:apsaratalent_mobile/features/application/providers/employer_workflow_provider.dart';
import 'package:apsaratalent_mobile/features/chat/data/chat_transport.dart';
import 'package:apsaratalent_mobile/features/chat/domain/chat_models.dart';
import 'package:apsaratalent_mobile/features/chat/providers/chat_controller.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/match/domain/entities/match_profile.dart';
import 'package:apsaratalent_mobile/features/match/providers/match_notifier.dart';
import 'package:apsaratalent_mobile/features/match/providers/match_realtime_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Transport implements ChatTransport {
  final controller = StreamController<ChatEvent>.broadcast();

  @override
  bool connected = true;

  @override
  Stream<ChatEvent> get events => controller.stream;

  @override
  Future<void> connect() async {}

  @override
  void dispose() => controller.close();

  @override
  void emit(String event, dynamic data) {}

  @override
  Future<dynamic> request(String event, [dynamic data]) async => null;
}

/// How many times each provider has built. A refetch is a second build.
final builds = <String, int>{};
void _built(String name) => builds[name] = (builds[name] ?? 0) + 1;

class _Matches extends MatchesNotifier {
  @override
  Future<MatchesState?> build() async {
    _built('matches');
    return null;
  }
}

class _Feed extends FeedNotifier {
  @override
  Future<FeedState?> build() async {
    _built('feed');
    return null;
  }
}

void main() {
  late _Transport transport;
  late ProviderContainer container;

  /// Keeps every provider alive, as an open screen would, and settles them.
  Future<void> readAll() async {
    for (final provider in <ProviderListenable<Object?>>[
      matchesProvider,
      feedProvider,
      matchCountProvider,
      employerInterviewsProvider,
      employeeInterviewsProvider,
    ]) {
      container.listen(provider, (_, __) {});
    }
    await container.read(matchesProvider.future);
    await container.read(feedProvider.future);
    await container.read(matchCountProvider.future);
    await container.read(employerInterviewsProvider.future);
    await container.read(employeeInterviewsProvider.future);
  }

  setUp(() async {
    builds.clear();
    transport = _Transport();
    container = ProviderContainer(overrides: [
      chatTransportProvider.overrideWithValue(transport),
      matchesProvider.overrideWith(_Matches.new),
      feedProvider.overrideWith(_Feed.new),
      matchCountProvider.overrideWith((ref) async {
        _built('count');
        return MatchCount.empty;
      }),
      employerInterviewsProvider.overrideWith((ref) async {
        _built('employerInterviews');
        return const <Interview>[];
      }),
      employeeInterviewsProvider.overrideWith((ref) async {
        _built('employeeInterviews');
        return const <Interview>[];
      }),
    ]);
    addTearDown(container.dispose);

    container.read(matchRealtimeSyncProvider);
    await readAll();
  });

  Future<Map<String, int>> push(String event) async {
    transport.controller.add(ChatEvent(event));
    await Future<void>.delayed(const Duration(milliseconds: 180));
    await readAll();
    return {for (final e in builds.entries) e.key: e.value - 1};
  }

  test('an unmatch refreshes matches, the badge, the feed and interviews',
      () async {
    expect(await push('unmatchUpdate'), {
      'matches': 1,
      'feed': 1,
      'count': 1,
      'employerInterviews': 1,
      'employeeInterviews': 1,
    });
  });

  test('a badge change refreshes the mounted account data', () async {
    expect(await push('badgeIncrement'), {
      'matches': 1,
      'feed': 1,
      'count': 1,
      'employerInterviews': 1,
      'employeeInterviews': 1,
    });
  });

  test('an interview change refreshes the mounted account data', () async {
    expect(await push('interviewUpdate'), {
      'matches': 1,
      'feed': 1,
      'count': 1,
      'employerInterviews': 1,
      'employeeInterviews': 1,
    });
  });

  test('an event this sync does not own refreshes nothing', () async {
    expect((await push('newMessage')).values, everyElement(0));
  });

  test('the socket subscribes to the names the gateway actually emits', () {
    // The gateway's matching and interview controllers send these. The app
    // used to listen for `unmatched`, which nothing ever sends.
    expect(
      SocketChatTransport.serverEvents,
      containsAll(['unmatchUpdate', 'badgeIncrement', 'interviewUpdate']),
    );
    expect(SocketChatTransport.serverEvents, isNot(contains('unmatched')));
  });
}
