import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/resume_builder/data/resume_repository.dart';
import '../../support/fake_http.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  ResumeRepository repository(FakeHttp http) => ResumeRepository(ApiClient(
      sessionStore: SessionStore(), baseUrl: 'http://api.test', adapter: http));
  test(
      'maps real profile collections to the resume contract without remote avatar',
      () {
    final draft = resumeFromProfile(
        const EmployeeProfile(
            id: 'e',
            fullName: 'Candidate',
            avatarUrl: 'https://example.com/avatar',
            skills: [
              'Flutter'
            ],
            experiences: [
              ProfileExperience(
                  title: 'Engineer', company: 'Company', startDate: '2024')
            ],
            educations: [
              ProfileEducation(
                  school: 'University', degree: 'BSc', year: '2023')
            ]),
        'me@example.com');
    expect(draft['personalInfo']['email'], 'me@example.com');
    expect(draft['personalInfo'].containsKey('profilePicture'), false);
    expect(draft['experience'][0]['position'], 'Engineer');
    expect(draft['experience'][0]['endDate'], 'Present');
    expect(draft['education'], 'BSc, University, 2023');
  });
  test('loads template keys from the backend catalog', () async {
    final http = FakeHttp((_) async => jsonResponse(200, [
          {'id': 'uuid', 'templateKey': 'classic', 'title': 'Classic'}
        ]));
    expect(
        (await repository(http).templates()).single['templateKey'], 'classic');
    expect(http.requests.single.path, '/resume/template/all');
  });
  test(
      'generation preserves identity and template without mutating original draft',
      () async {
    final draft = resumeFromProfile(
        const EmployeeProfile(id: 'e', fullName: 'Candidate'),
        'me@example.com');
    final http = FakeHttp((_) async => jsonResponse(200, {
          'personalInfo': {'fullName': 'Wrong'},
          'template': 'wrong',
          'skills': ['Dart'],
          'experience': [],
          'summary': 'Generated'
        }));
    final result = await repository(http).generate(draft);
    expect(result['personalInfo']['fullName'], 'Candidate');
    expect(result['template'], 'modern');
    expect(result['summary'], 'Generated');
    expect(draft['summary'], '');
    expect(http.requests.single.path, '/resume/generate');
    expect(http.requests.single.receiveTimeout, const Duration(minutes: 3));
  });
  test('build decodes PDF instead of treating base64 as a URL', () async {
    final bytes = utf8.encode('%PDF-1.7\nexample');
    final http = FakeHttp((_) async => jsonResponse(201, {
          'filename': '../../unsafe.pdf',
          'mimeType': 'application/pdf',
          'data': base64Encode(bytes)
        }));
    expect(await repository(http).build({}), bytes);
    expect(http.requests.single.path, '/resume/build-resume');
  });
  test('rejects malformed PDF content', () async {
    final http = FakeHttp((_) async => jsonResponse(201, {
          'mimeType': 'application/pdf',
          'data': base64Encode(utf8.encode('not a pdf'))
        }));
    await expectLater(repository(http).build({}), throwsA(isA<ApiException>()));
  });

  test('persists drafts per profile and ignores corrupt records', () async {
    const storage = FlutterSecureStorage();
    final store = ResumeDraftStore(storage: storage);
    final draft = {
      'template': 'modern',
      'personalInfo': {'fullName': 'Candidate'},
      'skills': ['Dart'],
    };
    await store.write('profile-a', draft);
    expect(await store.read('profile-a'), draft);
    expect(await store.read('profile-b'), isNull);
    await storage.write(key: 'resume.draft-profile-b', value: 'not-json');
    expect(await store.read('profile-b'), isNull);
    await store.clear('profile-a');
    expect(await store.read('profile-a'), isNull);
  });
  test('surfaces quota failures without losing the draft', () async {
    final draft = resumeFromProfile(
        const EmployeeProfile(id: 'e', fullName: 'Candidate'),
        'me@example.com');
    final before = jsonEncode(draft);
    final http = FakeHttp(
        (_) async => jsonResponse(429, {'message': 'AI quota exhausted'}));
    await expectLater(
        repository(http).generate(draft), throwsA(isA<ApiException>()));
    expect(jsonEncode(draft), before);
  });
}
