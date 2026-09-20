import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

void main() {
  const employee = FeedViewer(role: FeedViewerRole.employee, profileId: 'e1');
  const company = FeedViewer(role: FeedViewerRole.company, profileId: 'c1');

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  ProfileRepositoryImpl repositoryFor(FakeHttp http) => ProfileRepositoryImpl(
        ApiClient(
          sessionStore: SessionStore(),
          baseUrl: 'http://api.test',
          adapter: http,
        ),
      );

  // Trimmed from a real `/user/employee/one/:id` response.
  final employeeJson = {
    'id': 'e1',
    'firstname': 'Chenda',
    'lastname': 'Nhem',
    'username': 'chenda_nhem',
    'job': 'Sales Manager',
    'availability': 'available',
    'location': 'Phnom Penh',
    'email': 'chenda.nhem@seed.dev',
    // A `simple-array` column the seed leaves null.
    'languages': null,
    'skills': [
      {'id': 's1', 'name': 'Digital Marketing'},
    ],
    'experiences': [
      {'id': 'x1', 'title': 'Sales Representative', 'company': null},
    ],
    'educations': [
      {'id': 'd1', 'school': 'Build Bright University', 'degree': 'BBM'},
    ],
    'socials': <dynamic>[],
  };

  test('an employee viewer gets their employee record', () async {
    final http = FakeHttp((_) async => jsonResponse(200, employeeJson));

    final profile = await repositoryFor(http).fetchProfile(employee);

    expect(http.requests.single.path, '/user/employee/one/e1');
    expect(profile, isA<EmployeeProfile>());
    expect(profile.displayName, 'Chenda Nhem');
    expect(profile.headline, 'Sales Manager');

    final record = profile as EmployeeProfile;
    expect(record.skills, ['Digital Marketing']);
    // A null simple-array is an empty list, not a crash.
    expect(record.languages, isEmpty);
    // An experience with no company keeps the title alone.
    expect(record.experiences.single.summary, 'Sales Representative');
    expect(record.educations.single.summary, 'BBM · Build Bright University');
  });

  test('a company viewer gets their company record', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {
          'id': 'c1',
          'name': 'Smart Axiata',
          'industry': 'Telecommunications',
          'companySize': 900,
          'openPositions': [
            {'title': 'Backend Engineer'},
          ],
          'benefits': [
            {'label': 'Annual Bonus'},
          ],
        }));

    final profile = await repositoryFor(http).fetchProfile(company);

    expect(http.requests.single.path, '/user/company/one/c1');
    expect(profile, isA<CompanyProfile>());
    expect(profile.displayName, 'Smart Axiata');
    expect(profile.headline, 'Telecommunications');
    expect((profile as CompanyProfile).openPositions, ['Backend Engineer']);
  });

  test('a body that is not an object becomes a readable error', () async {
    final http = FakeHttp((_) async => jsonResponse(200, ['nope']));

    await expectLater(
      repositoryFor(http).fetchProfile(employee),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Could not load your profile.',
        ),
      ),
    );
  });
}
