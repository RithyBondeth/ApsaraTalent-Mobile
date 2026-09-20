import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/match/data/repositories/match_repository_impl.dart';
import 'package:apsaratalent_mobile/features/match/domain/entities/match_profile.dart';
import 'package:apsaratalent_mobile/features/match/domain/repositories/match_repository.dart';
import 'package:apsaratalent_mobile/features/match/providers/match_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

/// One row of `/match/current-employee-matching/:eid`, trimmed from the real
/// response. The counterpart profile is **flattened** — its own fields at the
/// top level with the two scores alongside — and it carries no benefits,
/// values or career scopes, unlike the feed list.
final matchRow = {
  'id': 'c9',
  'name': 'Smart Axiata',
  'industry': 'Telecommunications',
  'location': 'Phnom Penh',
  'companySize': 800,
  'foundedYear': 1996,
  'openPositions': [
    {'title': 'Backend Engineer', 'type': 'full_time'},
  ],
  'skillScore': 40,
  'matchScore': 62,
};

MatchProfile match(String id, {int score = 50}) => MatchProfile(
      profile: FeedCompany(id: id, name: 'Company $id'),
      matchScore: score,
      skillScore: 0,
    );

class FakeMatchRepository implements MatchRepository {
  List<MatchProfile> matches = [match('c1'), match('c2'), match('c3')];
  MatchCount count = const MatchCount(total: 3, unseen: 2);
  bool failUnmatch = false;
  bool failSeen = false;
  int seenCalls = 0;
  final List<String> unmatched = [];

  @override
  Future<List<MatchProfile>> fetchMatches(FeedViewer viewer) async => matches;

  @override
  Future<MatchCount> fetchCount(FeedViewer viewer) async => count;

  @override
  Future<MatchCount> markSeen(FeedViewer viewer) async {
    seenCalls++;
    if (failSeen) throw ApiException(message: 'seen failed');
    return count = MatchCount(total: count.total, unseen: 0);
  }

  @override
  Future<void> unmatch(FeedViewer viewer, String profileId) async {
    if (failUnmatch) throw ApiException(message: 'unmatch failed');
    unmatched.add(profileId);
    matches = matches.where((m) => m.profile.id != profileId).toList();
  }
}

void main() {
  const employee = FeedViewer(role: FeedViewerRole.employee, profileId: 'e1');
  const company = FeedViewer(role: FeedViewerRole.company, profileId: 'c1');

  group('parsing', () {
    test('reads the flattened counterpart and both scores', () {
      final parsed = MatchProfile.fromJson(matchRow, viewerIsEmployee: true);

      expect(parsed.profile, isA<FeedCompany>());
      expect(parsed.profile.id, 'c9');
      expect(parsed.profile.displayName, 'Smart Axiata');
      expect(parsed.matchScore, 62);
      expect(parsed.skillScore, 40);
    });

    test('a company viewer parses the row as an employee', () {
      final parsed = MatchProfile.fromJson(
        {'id': 'e9', 'firstname': 'Sophea', 'lastname': 'Chan', 'job': 'Dev'},
        viewerIsEmployee: false,
      );

      expect(parsed.profile, isA<FeedEmployee>());
      expect(parsed.profile.displayName, 'Sophea Chan');
      // Missing scores are zero, not a crash.
      expect(parsed.matchScore, 0);
    });

    test('a count reads total and unseen separately', () {
      final parsed = MatchCount.fromJson({'count': 7, 'unseenCount': 2});

      expect(parsed.total, 7);
      expect(parsed.unseen, 2);
    });
  });

  group('repository', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    MatchRepositoryImpl repositoryFor(FakeHttp http) => MatchRepositoryImpl(
          ApiClient(
            sessionStore: SessionStore(),
            baseUrl: 'http://api.test',
            adapter: http,
          ),
        );

    test('an employee asks the employee route', () async {
      final http = FakeHttp((_) async => jsonResponse(200, [matchRow]));

      final matches = await repositoryFor(http).fetchMatches(employee);

      expect(http.requests.single.path, '/match/current-employee-matching/e1');
      expect(matches.single.matchScore, 62);
    });

    test('unmatch puts the employee id first, whichever side asks', () async {
      // The route is always /match/unmatch/:eid/:cid, so a company's own id is
      // the second segment, not the first.
      final http = FakeHttp((_) async => jsonResponse(204, const <String, dynamic>{}));
      await repositoryFor(http).unmatch(company, 'e9');

      final request = http.requests.single;
      expect(request.method, 'DELETE');
      expect(request.path, '/match/unmatch/e9/c1');
    });

    test('an employee unmatching puts its own id first', () async {
      final http = FakeHttp((_) async => jsonResponse(204, const <String, dynamic>{}));
      await repositoryFor(http).unmatch(employee, 'c9');

      expect(http.requests.single.path, '/match/unmatch/e1/c9');
    });

    test('marking seen posts and returns the count left behind', () async {
      final http = FakeHttp(
        (_) async => jsonResponse(200, {'count': 3, 'unseenCount': 0}),
      );

      final count = await repositoryFor(http).markSeen(employee);

      expect(http.requests.single.method, 'POST');
      expect(http.requests.single.path, '/match/employee/e1/matching-seen');
      expect(count.unseen, 0);
    });
  });

  group('notifier', () {
    late FakeMatchRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeMatchRepository();
      container = ProviderContainer(overrides: [
        matchRepositoryProvider.overrideWithValue(repository),
        feedViewerProvider.overrideWithValue(employee),
      ]);
      addTearDown(container.dispose);
    });

    test('loads the matches for the signed-in viewer', () async {
      final state = await container.read(matchesProvider.future);

      expect(state!.matches.map((m) => m.profile.id), ['c1', 'c2', 'c3']);
    });

    test('unmatching removes the card and sends the profile id', () async {
      final state = await container.read(matchesProvider.future);

      await container
          .read(matchesProvider.notifier)
          .unmatch(state!.matches[1]);

      expect(repository.unmatched, ['c2']);
      final latest = container.read(matchesProvider).value!;
      expect(latest.matches.map((m) => m.profile.id), ['c1', 'c3']);
      expect(latest.isPending('c2'), isFalse);
    });

    test('unmatching invalidates the feed, because it un-likes too', () async {
      // Verified against the API: unmatch deletes the whole job_matching row,
      // which is where both sides' likes live. The feed hides liked profiles
      // from a set it loaded once, so it has to reload or it keeps hiding
      // someone the API no longer considers liked.
      final state = await container.read(matchesProvider.future);
      // Build the feed's viewer-derived state first so there is something to
      // invalidate, then confirm the unmatch disposed it.
      container.read(feedProvider);
      var feedRebuilt = false;
      container.listen(feedProvider, (_, __) => feedRebuilt = true);

      await container.read(matchesProvider.notifier).unmatch(state!.matches[0]);

      expect(repository.unmatched, ['c1']);
      expect(feedRebuilt, isTrue);
    });

    test('a failed unmatch puts the card back where it was', () async {
      final state = await container.read(matchesProvider.future);
      repository.failUnmatch = true;

      await expectLater(
        container.read(matchesProvider.notifier).unmatch(state!.matches[1]),
        throwsA(isA<ApiException>()),
      );

      final latest = container.read(matchesProvider).value!;
      expect(latest.matches.map((m) => m.profile.id), ['c1', 'c2', 'c3']);
      expect(latest.isPending('c2'), isFalse);
    });

    test('marking seen is skipped when there is nothing to see', () async {
      repository.matches = [];
      await container.read(matchesProvider.future);

      await container.read(matchesProvider.notifier).markSeen();

      expect(repository.seenCalls, 0);
    });

    test('a failed mark-seen is swallowed rather than shown', () async {
      // The badge staying up is small and self-correcting; an error about it
      // would interrupt reading the matches that did load.
      await container.read(matchesProvider.future);
      repository.failSeen = true;

      await container.read(matchesProvider.notifier).markSeen();

      expect(repository.seenCalls, 1);
      expect(container.read(matchesProvider).hasError, isFalse);
    });

    test('an account with no profile asks the API for nothing', () async {
      final none = ProviderContainer(overrides: [
        matchRepositoryProvider.overrideWithValue(repository),
        feedViewerProvider.overrideWithValue(null),
      ]);
      addTearDown(none.dispose);

      expect(await none.read(matchesProvider.future), isNull);
      expect(await none.read(matchCountProvider.future), MatchCount.empty);
    });
  });
}
