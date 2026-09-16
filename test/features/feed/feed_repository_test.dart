import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

void main() {
  const employee = FeedViewer(role: FeedViewerRole.employee, profileId: 'e1');
  const company = FeedViewer(role: FeedViewerRole.company, profileId: 'c1');

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  FeedRepositoryImpl repositoryFor(FakeHttp http) => FeedRepositoryImpl(
        ApiClient(
          sessionStore: SessionStore(),
          baseUrl: 'http://api.test',
          adapter: http,
        ),
      );

  // Trimmed from a real `/user/company/all` row.
  final companyJson = {
    'id': 'c9',
    'name': 'Sabay Digital',
    'industry': 'Media',
    'location': 'Phnom Penh',
    'companySize': 120,
    'foundedYear': 2007,
    'avatar': null,
    'openPositions': [
      {'title': 'Digital Marketing Manager', 'type': 'full_time', 'salary': r'$700'},
      {'title': '  '},
    ],
    'benefits': [
      {'id': 2, 'label': 'Annual Bonus'},
    ],
    'values': [
      {'id': 1, 'label': 'Innovation'},
    ],
    'careerScopes': [
      {'name': 'Software Development', 'description': null},
    ],
  };

  final employeeJson = {
    'id': 'e9',
    'firstname': 'Sophea',
    'lastname': 'Chan',
    'username': 'sophea',
    'job': 'Frontend Developer',
    'availability': 'full_time',
    'skills': [
      {'name': 'React'},
    ],
    'experiences': [
      {'title': 'Engineer', 'company': null},
    ],
    'educations': [
      {'degree': 'BSc', 'school': 'RUPP'},
    ],
  };

  test('an employee pages through companies with skip and limit', () async {
    final http = FakeHttp((_) async => jsonResponse(200, [companyJson]));

    final profiles =
        await repositoryFor(http).fetchProfiles(employee, skip: 20, limit: 10);

    final request = http.requests.single;
    expect(request.path, '/user/company/all');
    expect(request.queryParameters, {'skip': 20, 'limit': 10});

    final profile = profiles.single as FeedCompany;
    expect(profile.name, 'Sabay Digital');
    expect(profile.companySize, 120);
    // A blank position title is dropped, not rendered as an empty tag.
    expect(profile.openPositions.map((p) => p.title), ['Digital Marketing Manager']);
    expect(profile.benefits, ['Annual Bonus']);
    expect(profile.careerScopes, ['Software Development']);
  });

  test('a company sees employees, from its own recommendation route', () async {
    final http = FakeHttp((_) async => jsonResponse(200, [employeeJson]));

    final profiles = await repositoryFor(http).fetchRecommendations(company);

    expect(http.requests.single.path, '/user/recommendation/company/c1');
    final profile = profiles.single as FeedEmployee;
    expect(profile.displayName, 'Sophea Chan');
    expect(profile.skills, ['React']);
    expect(profile.experiences, ['Engineer']);
    expect(profile.educations, ['BSc · RUPP']);
  });

  test('favourites map the profile id to the favourite id', () async {
    final http = FakeHttp((_) async => jsonResponse(200, [
          {'id': 'fav1', 'company': companyJson},
          {'id': 'fav2', 'company': null},
        ]));

    final favorites = await repositoryFor(http).fetchFavorites(employee);

    expect(http.requests.single.path, '/user/employee/all-favorites/e1');
    expect(favorites, {'c9': 'fav1'});
  });

  test('a like reports whether it completed a match', () async {
    final http = FakeHttp((_) async => jsonResponse(201, {'isMatched': true}));

    final matched = await repositoryFor(http).like(company, 'e9');

    final request = http.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/match/company/c1/like/e9');
    expect(matched, isTrue);
  });

  test('unfavourite is a POST carrying the favourite id', () async {
    final http = FakeHttp((_) async => jsonResponse(201, {'message': 'ok'}));

    await repositoryFor(http).unfavorite(employee, 'c9', 'fav1');

    final request = http.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/user/employee/e1/unfavorite/fav1/company/c9');
  });

  test('a malformed body becomes a readable ApiException', () async {
    final http = FakeHttp((_) async => jsonResponse(200, [
          {'id': 'c1', 'companySize': 'many', 'openPositions': 'none'},
        ]));

    // Loose fields parse to nulls and empties rather than throwing.
    final profiles =
        await repositoryFor(http).fetchProfiles(employee, skip: 0, limit: 10);
    expect((profiles.single as FeedCompany).companySize, isNull);

    final broken = FakeHttp((_) async => jsonResponse(500, {'message': 'boom'}));
    expect(
      () => repositoryFor(broken).fetchLikedIds(employee),
      throwsA(isA<ApiException>()),
    );
  });

  test('humanize turns API keys into labels and leaves prose alone', () {
    expect(humanize('full_time'), 'Full time');
    expect(humanize('Full Time'), 'Full Time');
    expect(humanize('available'), 'Available');
  });
}
