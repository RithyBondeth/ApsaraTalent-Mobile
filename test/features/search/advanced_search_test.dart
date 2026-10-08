import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/saved_search/domain/entities/saved_search.dart';
import 'package:apsaratalent_mobile/features/saved_search/data/repositories/saved_search_repository_impl.dart';
import 'package:apsaratalent_mobile/features/search/data/repositories/search_repository_impl.dart';
import 'package:apsaratalent_mobile/features/search/providers/search_notifier.dart';
import 'package:apsaratalent_mobile/features/search/presentation/search_filters_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/fake_http.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  ApiClient client(FakeHttp http) => ApiClient(
      sessionStore: SessionStore(), baseUrl: 'http://api.test', adapter: http);
  const filters = {
    'location': 'Phnom Penh',
    'jobType': 'full_time',
    'experienceLevel': '3 - 5 years',
    'educationRequired': ['Bachelor', 'Master'],
    'salaryMin': 500,
    'salaryMax': 1000,
    'companySizeMin': 5,
    'companySizeMax': 50,
    'workMode': 'hybrid',
    'postedDateFrom': '2026-10-01T00:00:00.000Z',
    'postedDateTo': '2026-10-08T00:00:00.000Z',
    'sortBy': 'createdAt',
    'sortOrder': 'DESC'
  };
  test('job and talent queries send every selected filter on every page',
      () async {
    final http = FakeHttp((_) async =>
        jsonResponse(200, {'data': [], 'total': 0, 'page': 2, 'pageSize': 20}));
    final repo = SearchRepositoryImpl(client(http));
    await repo.searchJobs(
        keyword: '', page: 2, careerScopes: ['Software'], filters: filters);
    expect(http.requests.last.queryParameters, {
      ...filters,
      'page': 2,
      'pageSize': 20,
      'careerScopes': ['Software']
    });
    final talent = {
      'location': 'Phnom Penh',
      'jobType': 'contract',
      'experienceLevel': '3 - 5 years',
      'education': ['Bachelor'],
      'skills': ['Dart', 'TypeScript'],
      'sortBy': 'yearsOfExperience',
      'sortOrder': 'ASC'
    };
    await repo.searchTalent(keyword: 'Engineer', filters: talent);
    expect(http.requests.last.queryParameters,
        {...talent, 'keyword': 'Engineer', 'page': 1, 'pageSize': 20});
  });
  test('a filter-only search saved on web runs with its complete snapshot',
      () async {
    final http = FakeHttp((_) async =>
        jsonResponse(200, {'data': [], 'total': 0, 'page': 1, 'pageSize': 20}));
    final container = ProviderContainer(overrides: [
      searchModeProvider.overrideWithValue(SearchMode.jobs),
      searchRepositoryProvider
          .overrideWithValue(SearchRepositoryImpl(client(http)))
    ]);
    container.listen(searchProvider, (_, __) {});
    addTearDown(container.dispose);
    final saved = SavedSearch.fromJson({
      'id': 'saved-1',
      'name': 'Hybrid roles',
      'frequency': 'weekly',
      'filters': filters
    });
    await container.read(searchProvider.notifier).applySavedSearch(saved);
    expect(http.requests.single.queryParameters,
        {...filters, 'page': 1, 'pageSize': 20});
    expect(container.read(searchProvider)!.hasQuery, isTrue);
  });
  test('saving mobile filters stores the same shape as web', () async {
    final http = FakeHttp((request) async =>
        jsonResponse(201, {'id': 'saved-2', ...(request.data as Map)}));
    final saved = await SavedSearchRepositoryImpl(client(http))
        .create(name: 'Hybrid roles', keyword: '', filters: filters);
    expect((http.requests.single.data as Map)['filters'], {
      ...filters,
    });
    expect(saved.filters['salaryMin'], 500);
    expect(saved.hasOtherFilters, isFalse);
  });
  testWidgets('inverted salary ranges require correction before applying',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: const SearchFiltersScreen(
            jobs: true, filters: {'salaryMin': 1000, 'salaryMax': 500})));
    await tester.pumpAndSettle();
    final apply = find.text('Apply filters');
    await tester.ensureVisible(apply);
    await tester.tap(apply);
    await tester.pumpAndSettle();
    expect(find.text('Minimum cannot exceed maximum.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
