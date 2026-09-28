import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/saved_search/data/repositories/saved_search_repository_impl.dart';
import 'package:apsaratalent_mobile/features/saved_search/domain/entities/saved_search.dart';
import 'package:apsaratalent_mobile/features/saved_search/domain/repositories/saved_search_repository.dart';
import 'package:apsaratalent_mobile/features/saved_search/providers/saved_search_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

Map<String, dynamic> savedRow(
  String id, {
  String name = 'Design roles',
  String frequency = 'weekly',
}) =>
    {
      'id': id,
      'name': name,
      'filters': {
        'keyword': 'designer',
        'careerScopes': ['Design'],
      },
      'frequency': frequency,
      'createdAt': '2026-09-28T01:00:00.000Z',
    };

SavedSearch saved(String id,
        {SearchFrequency frequency = SearchFrequency.weekly}) =>
    SavedSearch.fromJson(savedRow(id, frequency: frequency.name));

class FakeSavedSearchRepository implements SavedSearchRepository {
  List<SavedSearch> items = [saved('s1')];
  bool failWrite = false;
  final List<String> calls = [];

  @override
  Future<List<SavedSearch>> fetchAll() async {
    calls.add('list');
    return items;
  }

  @override
  Future<SavedSearchPreview> preview(String id) async {
    calls.add('preview:$id');
    return const SavedSearchPreview(total: 12, newCount: 3);
  }

  @override
  Future<SavedSearch> create({
    required String name,
    required String keyword,
    List<String> careerScopes = const [],
    SearchFrequency frequency = SearchFrequency.weekly,
  }) async {
    calls.add('create:$name');
    final created = SavedSearch(
      id: 'created',
      name: name,
      keyword: keyword,
      careerScopes: careerScopes,
      frequency: frequency,
    );
    items = [created, ...items];
    return created;
  }

  @override
  Future<SavedSearch> setFrequency(
    String id,
    SearchFrequency frequency,
  ) async {
    calls.add('frequency:$id:${frequency.name}');
    if (failWrite) throw ApiException(message: 'write failed');
    final updated = items.firstWhere((item) => item.id == id).copyWith(
          frequency: frequency,
        );
    items = [
      for (final item in items)
        if (item.id == id) updated else item
    ];
    return updated;
  }

  @override
  Future<void> remove(String id) async {
    calls.add('remove:$id');
    if (failWrite) throw ApiException(message: 'write failed');
    items = items.where((item) => item.id != id).toList();
  }
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  SavedSearchRepositoryImpl repositoryFor(FakeHttp http) =>
      SavedSearchRepositoryImpl(
        ApiClient(
          sessionStore: SessionStore(),
          baseUrl: 'http://api.test',
          adapter: http,
        ),
      );

  group('parsing and repository', () {
    test('keeps understood filters and flags filters created on web', () {
      final parsed = SavedSearch.fromJson({
        ...savedRow('s1'),
        'filters': {
          'keyword': 'designer',
          'careerScopes': ['Design'],
          'workMode': 'remote',
        },
      });

      expect(parsed.keyword, 'designer');
      expect(parsed.careerScopes, ['Design']);
      expect(parsed.hasOtherFilters, isTrue);
    });

    test('creates the exact validated search snapshot', () async {
      final http = FakeHttp(
        (_) async => jsonResponse(201, savedRow('s1', frequency: 'daily')),
      );

      await repositoryFor(http).create(
        name: ' Design roles ',
        keyword: ' designer ',
        careerScopes: ['Design'],
        frequency: SearchFrequency.daily,
      );

      final request = http.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/job/saved-search');
      expect(request.data, {
        'name': 'Design roles',
        'filters': {
          'keyword': 'designer',
          'careerScopes': ['Design'],
        },
        'frequency': 'daily',
      });
    });

    test('uses the frequency, preview and delete routes', () async {
      final http = FakeHttp((request) async {
        if (request.path.endsWith('/preview')) {
          return jsonResponse(200, {'totalMatches': 8, 'newMatchCount': 2});
        }
        if (request.method == 'PATCH') {
          return jsonResponse(200, savedRow('s1', frequency: 'off'));
        }
        return jsonResponse(204, <String, dynamic>{});
      });
      final repository = repositoryFor(http);

      final updated = await repository.setFrequency('s1', SearchFrequency.off);
      final preview = await repository.preview('s1');
      await repository.remove('s1');

      expect(updated.frequency, SearchFrequency.off);
      expect(preview.total, 8);
      expect(preview.newCount, 2);
      expect(
        http.requests.map((request) => '${request.method} ${request.path}'),
        [
          'PATCH /job/saved-search/s1',
          'GET /job/saved-search/s1/preview',
          'DELETE /job/saved-search/s1',
        ],
      );
    });
  });

  group('notifier', () {
    late FakeSavedSearchRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeSavedSearchRepository();
      container = ProviderContainer(overrides: [
        savedSearchRepositoryProvider.overrideWithValue(repository),
      ]);
      container.listen(savedSearchesProvider, (_, __) {});
      addTearDown(container.dispose);
    });

    test('loads searches first and then their preview counts', () async {
      final initial = await container.read(savedSearchesProvider.future);
      expect(initial.items, hasLength(1));

      await pumpEventQueue();
      final latest = container.read(savedSearchesProvider).value!;
      expect(latest.previews['s1']?.total, 12);
      expect(latest.previews['s1']?.newCount, 3);
      expect(repository.calls, ['list', 'preview:s1']);
    });

    test('saving adds the API row and loads its preview', () async {
      await container.read(savedSearchesProvider.future);

      await container.read(savedSearchesProvider.notifier).save(
            name: 'Remote roles',
            keyword: 'engineer',
            careerScopes: ['Software Development'],
            frequency: SearchFrequency.daily,
          );

      final latest = container.read(savedSearchesProvider).value!;
      expect(latest.items.first.id, 'created');
      expect(latest.previews['created']?.total, 12);
    });

    test('a failed frequency change restores the old value', () async {
      await container.read(savedSearchesProvider.future);
      repository.failWrite = true;

      await expectLater(
        container
            .read(savedSearchesProvider.notifier)
            .setFrequency(saved('s1'), SearchFrequency.daily),
        throwsA(isA<ApiException>()),
      );

      final latest = container.read(savedSearchesProvider).value!;
      expect(latest.items.single.frequency, SearchFrequency.weekly);
      expect(latest.pendingIds, isEmpty);
    });

    test('deleting removes its row and preview', () async {
      await container.read(savedSearchesProvider.future);
      await pumpEventQueue();

      await container.read(savedSearchesProvider.notifier).remove(saved('s1'));

      final latest = container.read(savedSearchesProvider).value!;
      expect(latest.items, isEmpty);
      expect(latest.previews, isEmpty);
      expect(latest.pendingIds, isEmpty);
    });
  });
}
