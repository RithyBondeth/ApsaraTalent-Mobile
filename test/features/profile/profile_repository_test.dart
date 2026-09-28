import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
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
      {'id': 's1', 'name': 'Digital Marketing', 'description': 'Campaigns'},
    ],
    'careerScopes': [
      {'id': 'cs1', 'name': 'Marketing'},
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
    expect(record.skillItems.single.id, 's1');
    expect(record.skillItems.single.description, 'Campaigns');
    expect(record.careerScopeItems.single.id, 'cs1');
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
            {'id': 'j1', 'title': 'Backend Engineer'},
          ],
          'benefits': [
            {'label': 'Annual Bonus'},
          ],
          'images': [
            {'id': 'image-1', 'image': '/storage/company-images/office.png'},
          ],
        }));

    final profile = await repositoryFor(http).fetchProfile(company);

    expect(http.requests.single.path, '/user/company/one/c1');
    expect(profile, isA<CompanyProfile>());
    expect(profile.displayName, 'Smart Axiata');
    expect(profile.headline, 'Telecommunications');
    expect((profile as CompanyProfile).openPositions, ['Backend Engineer']);
    expect(profile.openPositionItems.single.id, 'j1');
    expect(profile.openPositionItems.single.title, 'Backend Engineer');
    expect(profile.images.single.id, 'image-1');
    expect(profile.images.single.url, '/storage/company-images/office.png');
  });

  test('uploads an employee resume with the required multipart field',
      () async {
    final http = FakeHttp((request) async => jsonResponse(200, {}));
    final repository = repositoryFor(http);

    await repository.uploadEmployeeDocument(
      'e1',
      EmployeeDocumentType.resume,
      ProfileUpload(
        filename: 'resume.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
    );

    expect(http.requests.map((r) => r.path), [
      '/user/current-user',
      '/user/employee/upload-resume/e1',
    ]);
    final form = http.requests.last.data as FormData;
    expect(form.files.single.key, 'resume');
    expect(form.files.single.value.filename, 'resume.pdf');
    expect(form.files.single.value.contentType.toString(), 'application/pdf');
  });

  test('uploads company gallery photos under repeated images fields', () async {
    final http = FakeHttp((request) async => jsonResponse(200, {}));
    final repository = repositoryFor(http);

    await repository.uploadCompanyImages('c1', [
      ProfileUpload(filename: 'one.jpg', bytes: Uint8List.fromList([1])),
      ProfileUpload(filename: 'two.png', bytes: Uint8List.fromList([2])),
    ]);

    expect(http.requests.last.path, '/user/company/upload-images/c1');
    final form = http.requests.last.data as FormData;
    expect(form.files.map((entry) => entry.key), ['images', 'images']);
    expect(form.files.map((entry) => entry.value.filename),
        ['one.jpg', 'two.png']);
  });

  test('downloads protected employee documents as bytes', () async {
    final http = FakeHttp((request) async => ResponseBody.fromBytes(
          [37, 80, 68, 70],
          200,
          headers: {
            Headers.contentTypeHeader: ['application/pdf'],
          },
        ));

    final bytes = await repositoryFor(http).downloadEmployeeDocument(
      'e1',
      EmployeeDocumentType.coverLetter,
    );

    expect(
        http.requests.single.path, '/user/employee/e1/document/cover-letter');
    expect(bytes, [37, 80, 68, 70]);
  });

  test('removes a company gallery image with DELETE', () async {
    final http = FakeHttp((request) async => jsonResponse(200, {}));

    await repositoryFor(http).removeCompanyImage('c1', 'image-1');

    expect(http.requests.single.method, 'DELETE');
    expect(http.requests.single.path, '/user/company/remove-images/c1/image-1');
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

  test('sends nested profile collections and scoped deletion ids unchanged',
      () async {
    final http = FakeHttp((request) async => jsonResponse(200, {
          'message': 'saved',
          'employee': employeeJson,
        }));
    final changes = {
      'skills': [
        {'id': 's1'},
        {'name': 'Flutter'},
      ],
      'experiences': [
        {'id': 'x1', 'title': 'Lead Engineer', 'company': 'Apsara'},
      ],
      'skillIdsToDelete': ['s2'],
      'educationIdsToDelete': ['d2'],
    };

    await repositoryFor(http).updateProfile(employee, changes);

    expect(http.requests.single.method, 'PATCH');
    expect(http.requests.single.path, '/user/employee/update-info/e1');
    expect(http.requests.single.data, changes);
  });
}
