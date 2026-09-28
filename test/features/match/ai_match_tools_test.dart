import 'dart:convert';

import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/match/data/repositories/ai_match_tools_repository.dart';
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
}
