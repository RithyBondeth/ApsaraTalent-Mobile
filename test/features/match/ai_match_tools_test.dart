import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/match/data/repositories/ai_match_tools_repository.dart';
import 'package:apsaratalent_mobile/features/match/data/interview_prep_export.dart';
import 'package:apsaratalent_mobile/features/match/domain/entities/ai_match_tools.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  AiMatchToolsRepository repositoryFor(FakeHttp http) =>
      AiMatchToolsRepository(ApiClient(
          sessionStore: SessionStore(),
          baseUrl: 'http://api.test',
          adapter: http));

  test('loads a structured match explanation', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {
          'score': 88,
          'verdict': 'Strong Match',
          'explanation': 'Good fit.',
          'strengths': ['Flutter'],
          'gaps': ['Docker'],
        }));
    final result = await repositoryFor(http).explanation('employee', 'company');
    expect(result.score, 88);
    expect(result.strengths, ['Flutter']);
    expect(http.requests.single.path, '/match/ai-explanation/employee/company');
    expect(http.requests.single.queryParameters, {'lang': 'en'});
  });

  test('parses streamed skill-gap NDJSON', () async {
    const ndjson = '{"t":"matched","skill":"Flutter"}\n'
        '{"t":"missing","skill":"Docker","criticality":"high","positions":["Mobile Engineer"],"tip":"Practice for ~2 weeks"}\n'
        '{"t":"summary","overallGap":"small","estimatedWeeks":2,"topPriority":"Learn Docker"}\n';
    final http = FakeHttp(
        (_) async => ResponseBody.fromBytes(utf8.encode(ndjson), 200, headers: {
              Headers.contentTypeHeader: ['application/x-ndjson']
            }));
    final result = await repositoryFor(http).skillGap('employee', 'company');
    expect(result.matchedSkills, ['Flutter']);
    expect(result.missingSkills.single.skill, 'Docker');
    expect(result.overallGap, 'small');
    expect(http.requests.single.responseType, ResponseType.stream);
  });

  test('loads interview questions and passes the round', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {
          'questions': [
            {
              'question': 'Tell me about Flutter',
              'questionKm': 'សំណួរ',
              'category': 'Technical',
              'tip': 'Use an example.',
              'tipKm': 'គន្លឹះ'
            }
          ]
        }));
    final result = await repositoryFor(http).interviewPrep(
        'employee', 'company',
        interviewTitle: 'Technical Round');
    expect(result.single.category, 'Technical');
    expect(http.requests.single.queryParameters,
        {'interviewTitle': 'Technical Round'});
  });

  test('builds the interview PDF payload and decodes a valid PDF', () async {
    final http = FakeHttp((request) async => jsonResponse(200, {
          'mimeType': 'application/pdf',
          'data': base64Encode(utf8.encode('%PDF-1.7\nprep')),
        }));
    final result = await repositoryFor(http).interviewPrepPdf(
      interviewTitle: '  Technical round  ',
      companyName: 'Company',
      companyIndustry: 'Technology',
      questions: const [
        InterviewQuestion(
            question: 'Tell me about Dart',
            questionKm: 'សំណួរ',
            category: 'Technical',
            tip: 'Use an example.',
            tipKm: 'គន្លឹះ')
      ],
    );
    expect(String.fromCharCodes(result.take(5)), '%PDF-');
    final request = http.requests.single;
    expect(request.path, '/resume/interview-prep-pdf');
    expect(request.data, {
      'interviewTitle': 'Technical round',
      'companyName': 'Company',
      'companyIndustry': 'Technology',
      'questions': [
        {
          'question': 'Tell me about Dart',
          'questionKm': 'សំណួរ',
          'category': 'Technical',
          'tip': 'Use an example.',
          'tipKm': 'គន្លឹះ'
        }
      ],
    });
  });

  test('rejects missing, wrong MIME, malformed base64, and non-PDF responses',
      () async {
    for (final body in [
      {
        'mimeType': 'application/json',
        'data': base64Encode(utf8.encode('%PDF-'))
      },
      {'mimeType': 'application/pdf', 'data': 'not-base64'},
      {
        'mimeType': 'application/pdf',
        'data': base64Encode(utf8.encode('not pdf'))
      },
    ]) {
      await expectLater(
          repositoryFor(FakeHttp((_) async => jsonResponse(200, body)))
              .interviewPrepPdf(
                  interviewTitle: '',
                  companyName: 'Company',
                  questions: const []),
          throwsA(isA<ApiException>()));
    }
  });

  test('reports device-opening failures and does not hide the platform message',
      () async {
    final dir = await Directory.systemTemp.createTemp('interview-prep-test');
    addTearDown(() => dir.delete(recursive: true));
    await expectLater(
      saveAndOpenInterviewPdf(
        Uint8List.fromList(utf8.encode('%PDF-1.7\nprep')),
        dir,
        opener: (_) async => OpenResult(
            type: ResultType.permissionDenied, message: 'Permission denied'),
      ),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', contains('Permission denied'))),
    );
  });

  test('does not write an invalid PDF before opening it', () async {
    final dir = await Directory.systemTemp.createTemp('interview-prep-invalid');
    addTearDown(() => dir.delete(recursive: true));
    await expectLater(
        saveAndOpenInterviewPdf(Uint8List.fromList(utf8.encode('bad')), dir),
        throwsA(isA<ApiException>()));
    expect(await File('${dir.path}/interview-prep.pdf').exists(), false);
  });
}
