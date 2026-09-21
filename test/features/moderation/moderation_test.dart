import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/moderation/data/repositories/moderation_repository_impl.dart';
import 'package:apsaratalent_mobile/features/moderation/domain/entities/moderation.dart';
import 'package:apsaratalent_mobile/features/moderation/domain/repositories/moderation_repository.dart';
import 'package:apsaratalent_mobile/features/moderation/providers/moderation_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

/// A row of `/user/moderation/blocked`. `id` is the **user** id.
Map<String, dynamic> blockedRow(String userId) => {
      'id': userId,
      'employeeId': null,
      'companyId': 'c9',
      'name': 'Sabay Digital',
      'avatar': null,
      'role': 'company',
      'blockedAt': '2026-09-21T03:00:00.000Z',
    };

BlockedUser blocked(String userId) =>
    BlockedUser.fromJson(blockedRow(userId));

class FakeModerationRepository implements ModerationRepository {
  List<BlockedUser> users = [blocked('u1'), blocked('u2')];
  bool fail = false;
  final List<String> calls = [];

  @override
  Future<List<BlockedUser>> fetchBlocked() async => users;

  @override
  Future<void> block(String userId) async {
    calls.add('block:$userId');
    if (fail) throw ApiException(message: 'block failed');
    users = [...users, blocked(userId)];
  }

  @override
  Future<void> unblock(String userId) async {
    calls.add('unblock:$userId');
    if (fail) throw ApiException(message: 'unblock failed');
    users = users.where((u) => u.userId != userId).toList();
  }

  @override
  Future<void> report(
    String userId, {
    required ReportReason reason,
    String? details,
  }) async {
    calls.add('report:$userId:${reason.key}');
    if (fail) throw ApiException(message: 'report failed');
  }
}

void main() {
  group('the user id moderation needs', () {
    test('a feed row carries one, lifted from the nested user', () {
      // Moderation is addressed by account, not by profile — so the feed
      // entity has to keep the user id the payload nests.
      final company = FeedCompany.fromJson({
        'id': 'c9',
        'name': 'Sabay Digital',
        'user': {'id': 'u1', 'email': 'hr@sabay-seed.dev'},
      });

      expect(company.id, 'c9');
      expect(company.userId, 'u1');
    });

    test('a trimmed row has none, so it cannot be moderated from there', () {
      // Favourites and matches nest no `user`. The sheet's entry point is
      // hidden rather than calling the API with a profile id.
      final company = FeedCompany.fromJson({'id': 'c9', 'name': 'Sabay'});

      expect(company.userId, isNull);
    });

    test('an employee row carries one too', () {
      final employee = FeedEmployee.fromJson({
        'id': 'e9',
        'firstname': 'Sophea',
        'user': {'id': 'u2'},
      });

      expect(employee.userId, 'u2');
    });
  });

  group('report reasons', () {
    test('map to the API keys, which are not all the enum names', () {
      expect(ReportReason.spam.key, 'spam');
      expect(ReportReason.inappropriateContent.key, 'inappropriate_content');
      expect(ReportReason.fakeProfile.key, 'fake_profile');
      expect(ReportReason.other.key, 'other');
    });
  });

  group('repository', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    ModerationRepositoryImpl repositoryFor(FakeHttp http) =>
        ModerationRepositoryImpl(
          ApiClient(
            sessionStore: SessionStore(),
            baseUrl: 'http://api.test',
            adapter: http,
          ),
        );

    test('blocking posts and unblocking deletes the same path', () async {
      final http = FakeHttp((_) async => jsonResponse(200, {'blocked': true}));
      await repositoryFor(http).block('u1');
      expect(http.requests.single.method, 'POST');
      expect(http.requests.single.path, '/user/moderation/block/u1');

      final http2 = FakeHttp((_) async => jsonResponse(200, {'blocked': false}));
      await repositoryFor(http2).unblock('u1');
      expect(http2.requests.single.method, 'DELETE');
      expect(http2.requests.single.path, '/user/moderation/block/u1');
    });

    test('a report sends the reason key and omits an empty note', () async {
      final http = FakeHttp((_) async => jsonResponse(201, {'ok': true}));

      await repositoryFor(http).report(
        'u1',
        reason: ReportReason.fakeProfile,
        details: '   ',
      );

      expect(http.requests.single.data, {
        'reportedId': 'u1',
        'reason': 'fake_profile',
      });
    });

    test('a report keeps a real note', () async {
      final http = FakeHttp((_) async => jsonResponse(201, {'ok': true}));

      await repositoryFor(http)
          .report('u1', reason: ReportReason.scam, details: 'Asked for money');

      expect(
        http.requests.single.data,
        containsPair('details', 'Asked for money'),
      );
    });

    test('the blocked list reads the user id, not a profile id', () async {
      final http = FakeHttp(
        (_) async => jsonResponse(200, [blockedRow('u1')]),
      );

      final users = await repositoryFor(http).fetchBlocked();

      expect(users.single.userId, 'u1');
      expect(users.single.name, 'Sabay Digital');
      expect(users.single.roleLabel, 'Company');
    });
  });

  group('notifier', () {
    late FakeModerationRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeModerationRepository();
      container = ProviderContainer(overrides: [
        moderationRepositoryProvider.overrideWithValue(repository),
      ]);
      addTearDown(container.dispose);
    });

    test('unblocking removes the row at once', () async {
      final state = await container.read(blockedProvider.future);

      await container.read(blockedProvider.notifier).unblock(state.users.first);

      expect(repository.calls, contains('unblock:u1'));
      final latest = container.read(blockedProvider).value!;
      expect(latest.users.map((u) => u.userId), ['u2']);
    });

    test('a failed unblock puts the row back', () async {
      final state = await container.read(blockedProvider.future);
      repository.fail = true;

      await expectLater(
        container.read(blockedProvider.notifier).unblock(state.users.first),
        throwsA(isA<ApiException>()),
      );

      final latest = container.read(blockedProvider).value!;
      expect(latest.users.map((u) => u.userId), ['u1', 'u2']);
      expect(latest.isPending('u1'), isFalse);
    });

    test('blocking is not optimistic — the list waits for the API', () async {
      // This list is the record of who is blocked. Showing someone on it
      // before the API agreed would claim something about another account
      // that might not be true.
      await container.read(blockedProvider.future);
      repository.fail = true;

      await expectLater(
        container.read(blockedProvider.notifier).block('u3'),
        throwsA(isA<ApiException>()),
      );

      expect(
        container.read(blockedProvider).value!.users.map((u) => u.userId),
        ['u1', 'u2'],
      );
    });

    test('reporting does not block', () async {
      // Separate on the API and separate here: reporting a bad job ad is not
      // the same as refusing to see that company again.
      await container
          .read(moderationActionsProvider)
          .report('u9', reason: ReportReason.spam);

      expect(repository.calls, ['report:u9:spam']);
      expect(repository.calls.where((c) => c.startsWith('block')), isEmpty);
    });
  });
}
