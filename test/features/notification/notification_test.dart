import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:apsaratalent_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:apsaratalent_mobile/features/notification/domain/repositories/notification_repository.dart';
import 'package:apsaratalent_mobile/features/notification/providers/notification_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

/// A real row from `GET /notification`, as the API wrote it after a match.
Map<String, dynamic> row(
  String id, {
  bool isRead = false,
  String type = 'match',
}) =>
    {
      'id': id,
      'title': "It's a Match!",
      'message': 'Smart Axiata and you liked each other!',
      'type': type,
      'data': {
        'companyId': 'c9',
        'eventType': 'match',
        'employeeId': 'e1',
        'senderName': 'Smart Axiata',
        'senderAvatar': null,
      },
      'isRead': isRead,
      'createdAt': '2026-09-20T13:45:45.881Z',
    };

Map<String, dynamic> envelope(List<Map<String, dynamic>> items, {int? total}) =>
    {
      'items': items,
      'total': total ?? items.length,
      'page': 1,
      'limit': 20,
    };

AppNotification note(String id, {bool isRead = false}) =>
    AppNotification.fromJson(row(id, isRead: isRead));

class FakeNotificationRepository implements NotificationRepository {
  List<AppNotification> items =
      List.generate(25, (i) => note('n$i'));
  bool fail = false;
  final List<String> calls = [];

  @override
  Future<NotificationPage> fetchPage({
    required int page,
    required int limit,
  }) async {
    calls.add('page$page');
    if (fail) throw ApiException(message: 'list failed');
    final start = (page - 1) * limit;
    return NotificationPage(
      items: items.skip(start).take(limit).toList(),
      total: items.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<void> markRead(String id) async {
    calls.add('read:$id');
    if (fail) throw ApiException(message: 'read failed');
  }

  @override
  Future<void> markAllRead() async {
    calls.add('read-all');
    if (fail) throw ApiException(message: 'read-all failed');
  }

  @override
  Future<void> remove(String id) async {
    calls.add('delete:$id');
    if (fail) throw ApiException(message: 'delete failed');
    items = items.where((n) => n.id != id).toList();
  }

  @override
  Future<void> clearAll() async {
    calls.add('clear');
    if (fail) throw ApiException(message: 'clear failed');
    items = [];
  }
}

void main() {
  group('parsing', () {
    test('reads a row and lifts the sender out of data', () {
      final parsed = AppNotification.fromJson(row('n1'));

      expect(parsed.id, 'n1');
      expect(parsed.title, "It's a Match!");
      expect(parsed.kind, NotificationKind.match);
      expect(parsed.isRead, isFalse);
      expect(parsed.senderName, 'Smart Axiata');
      expect(parsed.senderAvatarUrl, isNull);
    });

    test('an unknown type still renders rather than being dropped', () {
      // A type the app has not heard of is far more likely to be new than
      // wrong, so it gets a generic kind instead of disappearing.
      final parsed = AppNotification.fromJson(row('n1', type: 'promotion'));

      expect(parsed.kind, NotificationKind.other);
      expect(parsed.kind.label, 'Update');
    });

    test('the envelope carries the API total, not the page length', () {
      // How many exist is known, so "more pages" never has to be guessed
      // from a short page the way the feed does it.
      final page = NotificationPage.fromJson(
        envelope([row('n1'), row('n2')], total: 57),
      );

      expect(page.items, hasLength(2));
      expect(page.total, 57);
      expect(page.page, 1);
    });

    test('a missing createdAt leaves the age blank rather than lying', () {
      final parsed = AppNotification.fromJson({'id': 'n1', 'title': 'x'});

      expect(parsed.age, isEmpty);
      expect(parsed.createdAt, isNull);
    });
  });

  group('repository', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    NotificationRepositoryImpl repositoryFor(FakeHttp http) =>
        NotificationRepositoryImpl(
          ApiClient(
            sessionStore: SessionStore(),
            baseUrl: 'http://api.test',
            adapter: http,
          ),
        );

    test('pages with page and limit, not skip', () async {
      final http = FakeHttp((_) async => jsonResponse(200, envelope([row('n1')])));

      await repositoryFor(http).fetchPage(page: 3, limit: 20);

      final request = http.requests.single;
      expect(request.path, '/notification');
      expect(request.queryParameters, {'page': 3, 'limit': 20});
    });

    test('marking one read patches its own route', () async {
      final http = FakeHttp((_) async => jsonResponse(200, <String, dynamic>{}));

      await repositoryFor(http).markRead('n1');

      expect(http.requests.single.method, 'PATCH');
      expect(http.requests.single.path, '/notification/n1/read');
    });

    test('clearing all deletes the collection, not an id', () async {
      final http = FakeHttp((_) async => jsonResponse(200, <String, dynamic>{}));

      await repositoryFor(http).clearAll();

      expect(http.requests.single.method, 'DELETE');
      expect(http.requests.single.path, '/notification');
    });

    test('a body that is not an envelope becomes a readable error', () async {
      final http = FakeHttp((_) async => jsonResponse(200, [row('n1')]));

      await expectLater(
        repositoryFor(http).fetchPage(page: 1, limit: 20),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('notifier', () {
    late FakeNotificationRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeNotificationRepository();
      container = ProviderContainer(overrides: [
        notificationRepositoryProvider.overrideWithValue(repository),
      ]);
      addTearDown(container.dispose);
    });

    test('loads the first page and knows more exist from the total', () async {
      final state = await container.read(notificationsProvider.future);

      expect(state.items, hasLength(20));
      expect(state.total, 25);
      expect(state.hasMore, isTrue);
      expect(state.unread, 20);
    });

    test('paging appends and stops when the total is reached', () async {
      await container.read(notificationsProvider.future);

      await container.read(notificationsProvider.notifier).loadMore();

      final state = container.read(notificationsProvider).value!;
      expect(state.items, hasLength(25));
      expect(state.hasMore, isFalse);
      expect(repository.calls, ['page1', 'page2']);
    });

    test('marking read is optimistic and rolls back on failure', () async {
      final state = await container.read(notificationsProvider.future);
      repository.fail = true;

      await expectLater(
        container
            .read(notificationsProvider.notifier)
            .markRead(state.items.first),
        throwsA(isA<ApiException>()),
      );

      final latest = container.read(notificationsProvider).value!;
      expect(latest.items.first.isRead, isFalse);
      expect(latest.isPending(state.items.first.id), isFalse);
    });

    test('an already-read notification costs no request', () async {
      repository.items = [note('n1', isRead: true)];
      final state = await container.read(notificationsProvider.future);

      await container
          .read(notificationsProvider.notifier)
          .markRead(state.items.first);

      expect(repository.calls, ['page1']);
    });

    test('deleting drops the total too, so paging stays honest', () async {
      final state = await container.read(notificationsProvider.future);

      await container
          .read(notificationsProvider.notifier)
          .remove(state.items.first);

      final latest = container.read(notificationsProvider).value!;
      expect(latest.items, hasLength(19));
      expect(latest.total, 24);
    });

    test('a failed delete puts the row back', () async {
      final state = await container.read(notificationsProvider.future);
      repository.fail = true;

      await expectLater(
        container
            .read(notificationsProvider.notifier)
            .remove(state.items.first),
        throwsA(isA<ApiException>()),
      );

      final latest = container.read(notificationsProvider).value!;
      expect(latest.items, hasLength(20));
      expect(latest.total, 25);
    });

    test('a failed clear-all restores the whole list', () async {
      await container.read(notificationsProvider.future);
      repository.fail = true;

      await expectLater(
        container.read(notificationsProvider.notifier).clearAll(),
        throwsA(isA<ApiException>()),
      );

      expect(container.read(notificationsProvider).value!.items, hasLength(20));
    });
  });
}
