import 'package:apsaratalent_mobile/features/auth/data/models/registration_request.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/presentation/widgets/profile_collections_editor.dart';
import 'package:apsaratalent_mobile/features/resume_import/data/resume_import_repository.dart';
import 'package:apsaratalent_mobile/features/resume_import/presentation/resume_import_button.dart';
import '../../support/fake_http.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  ResumeImportRepository repository(FakeHttp http) =>
      ResumeImportRepository(ApiClient(
          sessionStore: SessionStore(),
          baseUrl: 'http://api.test',
          adapter: http));
  final pdf = Uint8List.fromList('%PDF-1.7\nresume'.codeUnits);

  test('posts public multipart PDF with the correct field and MIME type',
      () async {
    final http = FakeHttp((_) async => jsonResponse(200, {
          'firstName': 'Sokha',
          'skills': ['Dart']
        }));
    final result = await repository(http).parse('Resume.PDF', pdf);
    final request = http.requests.single;
    expect(request.path, '/auth/parse-resume');
    expect(request.method, 'POST');
    expect(request.extra['session.public'], true);
    final part = (request.data as FormData).files.single;
    expect(part.key, 'resume');
    expect(part.value.contentType.toString(), 'application/pdf');
    expect(result['firstname'], 'Sokha');
  });
  test('rejects invalid files and oversize PDFs before calling the API',
      () async {
    final http = FakeHttp((_) async => jsonResponse(200, {}));
    await expectLater(repository(http).parse('resume.docx', pdf),
        throwsA(isA<ApiException>()));
    await expectLater(repository(http).parse('resume.pdf', Uint8List(10)),
        throwsA(isA<ApiException>()));
    final large = Uint8List(maxResumeImportBytes + 1)
      ..setRange(0, 5, '%PDF-'.codeUnits);
    await expectLater(repository(http).parse('resume.pdf', large),
        throwsA(isA<ApiException>()));
    expect(http.requests, isEmpty);
  });
  test(
      'normalizes parser output without credentials, IDs, invalid choices or dates',
      () {
    final result = normalizeResumeImport({
      'firstName': ' Sokha ',
      'email': 'someone@example.com',
      'phone': '123',
      'password': 'secret',
      'location': 'Unknown',
      'availability': 'invalid',
      'skills': ['Dart', 'Dart', null, ''],
      'careerScopes': ['Software Engineering', 'invalid'],
      'educations': [
        {'id': 'injected', 'school': 'University', 'year': 2024}
      ],
      'experiences': [
        {
          'id': 'injected',
          'title': 'Engineer',
          'startDate': '2024-02-31',
          'endDate': 'Present'
        }
      ],
    }, careerScopes: {
      'Software Engineering'
    });
    expect(result['firstname'], 'Sokha');
    expect(result.keys, isNot(contains('email')));
    expect(result.keys, isNot(contains('phone')));
    expect(result.keys, isNot(contains('location')));
    expect(result['skills'], ['Dart']);
    expect(result['careerScopes'], ['Software Engineering']);
    expect(result['educations'], [
      {'school': 'University', 'year': '2024'}
    ]);
    expect(result['experiences'], [
      {'title': 'Engineer'}
    ]);
    expect(signupResumeExperiences(result['experiences']), isEmpty);
  });
  test('empty, malformed and failed parses return actionable errors', () async {
    for (final data in [
      {},
      [],
      {
        'skills': [null]
      }
    ]) {
      await expectLater(
          repository(FakeHttp((_) async => jsonResponse(200, data)))
              .parse('resume.pdf', pdf),
          throwsA(isA<ApiException>()));
    }
    await expectLater(
        repository(FakeHttp(
                (_) async => jsonResponse(429, {'message': 'Rate limit'})))
            .parse('resume.pdf', pdf),
        throwsA(isA<ApiException>()));
  });
  test(
      'reviewed education and complete history survive registration serialization',
      () {
    final parsed = normalizeResumeImport({
      'experiences': [
        {
          'title': 'Engineer',
          'description': 'Built apps',
          'startDate': '2023-01-01',
          'endDate': '2024-01-01'
        },
        {'title': 'Incomplete role'}
      ],
      'educations': [
        {'school': 'University', 'year': 2022}
      ],
    });
    final payload = EmployeeRegistration(
            email: 'login@example.com',
            password: 'password',
            firstname: 'Sokha',
            lastname: 'Chan',
            username: 'sokha',
            gender: 'male',
            dob: DateTime(2000),
            location: 'Phnom Penh',
            job: 'Engineer',
            yearsOfExperience: '1 - 2 years',
            availability: 'full_time',
            careerScopes: ['Software Engineering'],
            skills: ['Dart'],
            experiences: signupResumeExperiences(parsed['experiences']),
            educations: List<Map<String, dynamic>>.from(parsed['educations']))
        .toJson();
    expect((payload['experiences'] as List).length, 1);
    expect(payload['experiences'][0]['startDate'], '2023-01-01');
    expect(payload['educations'][0]['year'], '2022');
    expect(payload['email'], 'login@example.com');
  });
  testWidgets('review allows deselecting fields before applying',
      (tester) async {
    Map<String, dynamic>? applied;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () async {
                      applied = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (_) => const ResumeImportReview(data: {
                                'firstname': 'Sokha',
                                'skills': ['Dart']
                              }));
                    },
                    child: const Text('Review'))))));
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('First name'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply selected'));
    await tester.pumpAndSettle();
    expect(applied, {
      'skills': ['Dart']
    });
  });
  testWidgets(
      'collection import preserves existing IDs and unsaved additions and avoids duplicate imports',
      (tester) async {
    final key = GlobalKey<ProfileCollectionsEditorState>();
    final changes = <String, dynamic>{};
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
            body: SingleChildScrollView(
                child: ProfileCollectionsEditor(
          key: key,
          profile: const EmployeeProfile(
              id: 'e',
              fullName: 'Candidate',
              skillItems: [
                ProfileNamedItem(id: 'skill-id', name: 'Flutter')
              ],
              experiences: [
                ProfileExperience(
                    id: 'job-id', title: 'Developer', company: 'Old company')
              ]),
          onChanged: changes.addAll,
        )))));
    final imported = {
      'skills': ['Dart'],
      'experiences': [
        {
          'title': 'Engineer',
          'company': 'New company',
          'startDate': '2024-01-01'
        }
      ]
    };
    key.currentState!.importResume(imported);
    await tester.pump();
    key.currentState!.importResume(imported);
    await tester.pump();
    expect((changes['skills'] as List).first['id'], 'skill-id');
    expect((changes['skills'] as List).length, 2);
    expect((changes['experiences'] as List).first['id'], 'job-id');
    expect((changes['experiences'] as List).length, 2);
    expect(changes['experienceIdsToDelete'], isNull);
    expect(tester.takeException(), isNull);
  });
}
