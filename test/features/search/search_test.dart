import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/search/data/repositories/search_repository_impl.dart';
import 'package:apsaratalent_mobile/features/search/domain/entities/job_posting.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

/// A row from `/job/search`. Search answers `experience` and `education`.
Map<String, dynamic> searchRow = {
  'id': 'j1',
  'title': 'React Developer',
  'description': 'Build and maintain our consumer-facing web applications.',
  'type': 'full_time',
  'salary': r'$800 - $1,500/month',
  'location': null,
  'workMode': null,
  'openingsCount': null,
  'experience': '2+ years',
  'education': "Bachelor's degree",
  'skills': ['JavaScript', 'React', 'TypeScript'],
  'company': {
    'id': 'c9',
    'name': 'Sabay Digital',
    'avatar': null,
    'industry': 'Technology',
    'location': 'Phnom Penh',
  },
};

/// The same posting from `/public/job/:id`, which names those two fields
/// differently.
Map<String, dynamic> detailRow = {
  ...searchRow,
  'experience': null,
  'education': null,
  'experienceRequired': '2+ years',
  'educationRequired': "Bachelor's degree",
};

Map<String, dynamic> envelope(
  List<Map<String, dynamic>> data, {
  int? total,
  bool fallback = false,
}) =>
    {
      'data': data,
      'total': total ?? data.length,
      'page': 1,
      'pageSize': 20,
      'isUsingFallback': fallback,
    };

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  SearchRepositoryImpl repositoryFor(FakeHttp http) => SearchRepositoryImpl(
        ApiClient(
          sessionStore: SessionStore(),
          baseUrl: 'http://api.test',
          adapter: http,
        ),
      );

  group('parsing', () {
    test('reads a posting and its nested company', () {
      final job = JobPosting.fromJson(searchRow);

      expect(job.id, 'j1');
      expect(job.title, 'React Developer');
      expect(job.company?.name, 'Sabay Digital');
      expect(job.skills, ['JavaScript', 'React', 'TypeScript']);
      expect(job.typeLabel, 'Full time');
    });

    test('reads the requirement fields under either name', () {
      // Search says experience/education; /public/job/:id says
      // experienceRequired/educationRequired. Same posting, same data.
      expect(JobPosting.fromJson(searchRow).experience, '2+ years');
      expect(JobPosting.fromJson(detailRow).experience, '2+ years');
      expect(
        JobPosting.fromJson(detailRow).education,
        "Bachelor's degree",
      );
    });

    test('falls back to the company location when the posting has none', () {
      // Every seeded posting has a null location; the company knows where it
      // is, so a card can still say.
      expect(JobPosting.fromJson(searchRow).where, 'Phnom Penh');
    });
  });

  group('query parameters', () {
    test('sends keyword, not q', () async {
      // `q` is accepted and ignored: it returns every posting, so a search
      // would look like it worked and filter nothing.
      final http = FakeHttp((_) async => jsonResponse(200, envelope([])));

      await repositoryFor(http).searchJobs(keyword: 'developer');

      final query = http.requests.single.queryParameters;
      expect(query['keyword'], 'developer');
      expect(query.containsKey('q'), isFalse);
    });

    test('omits careerScopes entirely when narrowing is off', () async {
      // An empty list would still switch the API's scope filter on, and with
      // it the silent fallback.
      final http = FakeHttp((_) async => jsonResponse(200, envelope([])));

      await repositoryFor(http).searchJobs(keyword: 'developer');

      expect(
        http.requests.single.queryParameters.containsKey('careerScopes'),
        isFalse,
      );
    });

    test('sends scope names as a repeated key, not the bracket form', () async {
      // Dio's default is `careerScopes[]=a`, which this API does not parse —
      // the filter is dropped and every posting comes back.
      final http = FakeHttp((_) async => jsonResponse(200, envelope([])));

      await repositoryFor(http).searchJobs(
        keyword: 'developer',
        careerScopes: ['Software Development', 'Design'],
      );

      final request = http.requests.single;
      expect(request.queryParameters['careerScopes'],
          ['Software Development', 'Design']);
      expect(request.listFormat, ListFormat.multi);
    });

    test('talent search asks the employee route', () async {
      final http = FakeHttp((_) async => jsonResponse(200, envelope([])));

      await repositoryFor(http).searchTalent(keyword: 'sales');

      expect(http.requests.single.path, '/user/employee/search-employee');
    });
  });

  group('results', () {
    test('carries the fallback flag off the envelope', () async {
      // The API narrowed, found nothing, and retried unfiltered. The screen
      // has to say so.
      final http = FakeHttp(
        (_) async => jsonResponse(200, envelope([searchRow], fallback: true)),
      );

      final results = await repositoryFor(http)
          .searchJobs(keyword: 'developer', careerScopes: ['Nope']);

      expect(results.usedFallback, isTrue);
      expect(results.items, hasLength(1));
    });

    test('knows more pages exist from the total', () async {
      final http = FakeHttp(
        (_) async => jsonResponse(200, envelope([searchRow], total: 40)),
      );

      final results = await repositoryFor(http).searchJobs(keyword: 'a');

      expect(results.hasMore, isTrue);
      expect(results.total, 40);
    });

    test('a body that is not an envelope reads as empty', () async {
      final http = FakeHttp((_) async => jsonResponse(200, [searchRow]));

      final results = await repositoryFor(http).searchJobs(keyword: 'a');

      expect(results.items, isEmpty);
      expect(results.usedFallback, isFalse);
    });
  });

  group('one posting', () {
    test('reads the public route by id', () async {
      final http = FakeHttp((_) async => jsonResponse(200, detailRow));

      final job = await repositoryFor(http).fetchJob('j1');

      expect(http.requests.single.path, '/public/job/j1');
      expect(job.title, 'React Developer');
      expect(job.experience, '2+ years');
    });

    test('a body that is not an object becomes a readable error', () async {
      final http = FakeHttp((_) async => jsonResponse(200, ['nope']));

      await expectLater(
        repositoryFor(http).fetchJob('j1'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
