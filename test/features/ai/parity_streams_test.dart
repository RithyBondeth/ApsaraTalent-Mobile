import 'dart:convert';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/ai/data/ai_repository.dart';
import 'package:apsaratalent_mobile/features/match/data/repositories/ai_match_tools_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/fake_http.dart';

ResponseBody sse(List<String> chunks, {bool done = true}) =>
    ResponseBody.fromString(
        '${chunks.map((v) => 'data: ${jsonEncode({
                  't': 'chunk',
                  'v': v
                })}\n\n').join()}'
        '${done ? 'data: {"t":"done"}\n\n' : ''}',
        200,
        headers: {
          Headers.contentTypeHeader: ['text/event-stream']
        });

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  ApiClient client(FakeHttp http) => ApiClient(
      sessionStore: SessionStore(), baseUrl: 'http://api.test', adapter: http);
  test('letter and polishing use gateway SSE with incremental Khmer preview',
      () async {
    final http = FakeHttp((_) async => sse(['ជំរាបសួរ', ' hiring team']));
    final repo = AiRepository(client(http));
    final preview = <String>[];
    expect(
        await repo.coverLetterStream({'employeeName': 'Candidate'},
            onChunk: preview.add),
        'ជំរាបសួរ hiring team');
    expect(preview, ['ជំរាបសួរ', 'ជំរាបសួរ hiring team']);
    expect(http.requests.last.path, '/resume/cover-letter/stream');
    expect(http.requests.last.responseType, ResponseType.stream);
    await repo.polishStream('My draft');
    expect(http.requests.last.path, '/resume/polish-cover-letter/stream');
    expect(http.requests.last.data, {'coverLetterText': 'My draft'});
  });
  test('partial AI writing never becomes a completed draft', () async {
    final repo = AiRepository(
        client(FakeHttp((_) async => sse(['partial'], done: false))));
    await expectLater(repo.coverLetterStream({}), throwsA(isA<ApiException>()));
  });
  test('interview question JSON can cross SSE chunk boundaries', () async {
    final question = jsonEncode({
      'question': 'Tell me about Dart',
      'questionKm': 'សំណួរ',
      'category': 'Technical',
      'tip': 'Give an example.',
      'tipKm': 'គន្លឹះ'
    });
    final http = FakeHttp((_) async =>
        sse([question.substring(0, 12), '${question.substring(12)}\n']));
    final previews = <int>[];
    final rows = await AiMatchToolsRepository(client(http)).interviewPrepStream(
        'employee', 'company',
        interviewTitle: '  Technical round  ',
        onQuestions: (questions) => previews.add(questions.length));
    expect(rows.single.questionKm, 'សំណួរ');
    expect(previews, [1]);
    expect(http.requests.single.path,
        '/match/ai-interview-prep/employee/company/stream');
    expect(http.requests.single.queryParameters,
        {'interviewTitle': 'Technical round'});
  });
  test('truncated interview stream reports failure even after a preview',
      () async {
    final http = FakeHttp(
        (_) async => sse(['{"question":"Q","tip":"T"}\n'], done: false));
    await expectLater(
        AiMatchToolsRepository(client(http))
            .interviewPrepStream('employee', 'company'),
        throwsA(isA<ApiException>()));
  });
  test('SSE HTTP errors preserve quota and validation messages', () async {
    for (final entry in [
      (
        429,
        {'message': 'Daily AI usage limit reached. Try again tomorrow.'},
        'Daily AI usage limit reached. Try again tomorrow.'
      ),
      (
        400,
        {
          'message': ['name is required', 'text is required']
        },
        'name is required\ntext is required'
      ),
    ]) {
      final http = FakeHttp((_) async => jsonResponse(entry.$1, entry.$2));
      await expectLater(
          AiRepository(client(http)).coverLetterStream({}),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'status', entry.$1)
              .having((e) => e.message, 'message', entry.$3)));
    }
  });
  test('malformed stream error bodies still report their HTTP status',
      () async {
    final http = FakeHttp(
        (_) async => ResponseBody.fromString('bad upstream body', 502));
    await expectLater(
        AiRepository(client(http)).coverLetterStream({}),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'status', 502)
            .having((e) => e.message, 'message', 'Server error')));
  });
}
