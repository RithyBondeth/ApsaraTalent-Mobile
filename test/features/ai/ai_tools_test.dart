import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/ai/data/ai_repository.dart';
import 'package:apsaratalent_mobile/features/ai/presentation/ai_quota.dart';
import 'package:apsaratalent_mobile/features/ai/presentation/ai_writing_screen.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_button.dart';
import '../../support/fake_http.dart';

Map<String, dynamic> quotaData({int remaining = 7, int cv = 2}) => {
      'daily': {'remaining': remaining, 'limit': 100, 'used': 100 - remaining},
      'actions': {
        'cvGeneration': {'remaining': cv, 'limit': 3, 'used': 3 - cv}
      },
      'resetsAt':
          DateTime.now().add(const Duration(days: 1)).toUtc().toIso8601String(),
    };

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  ApiClient client(FakeHttp http) => ApiClient(
      sessionStore: SessionStore(), baseUrl: 'http://api.test', adapter: http);

  test(
      'quota reads server allowances and rejects malformed data instead of inventing zero',
      () async {
    final http = FakeHttp((_) async => jsonResponse(200, quotaData()));
    final quota = await AiRepository(client(http)).quota();
    expect(quota.remaining, 7);
    expect(quota.cvRemaining, 2);
    expect(http.requests.single.path, '/ai/quota');
    expect(() => AiQuota.fromJson({}), throwsA(isA<ApiException>()));
  });
  test('global and CV quotas gate only the applicable actions', () async {
    var calls = 0;
    Future<String> action() async {
      calls++;
      return 'done';
    }

    final cvOnly = AiRepository(
        client(FakeHttp((_) async => jsonResponse(200, quotaData(cv: 0)))));
    await expectLater(
        cvOnly.run(action, cvGeneration: true), throwsA(isA<ApiException>()));
    expect(calls, 0);
    expect(await cvOnly.run(action), 'done');
    final empty = AiRepository(client(
        FakeHttp((_) async => jsonResponse(200, quotaData(remaining: 0)))));
    await expectLater(empty.run(action), throwsA(isA<ApiException>()));
    expect(calls, 1);
  });
  test('expired quota snapshot does not lock the next day', () {
    final data = quotaData(remaining: 0, cv: 0)
      ..['resetsAt'] =
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
    expect(AiQuota.fromJson(data).exhausted(cvGeneration: true), false);
  });
  test('cover letter and polish use the API contracts', () async {
    final http = FakeHttp((_) async => jsonResponse(
        200, {'coverLetter': 'Dear Hiring Team,\nA tailored draft.'}));
    final repo = AiRepository(client(http));
    final payload = {
      'employeeName': 'Sokha',
      'employeeSkills': ['Dart'],
      'companyName': 'Company',
      'openPositions': ['Engineer']
    };
    expect(await repo.coverLetter(payload), contains('tailored draft'));
    expect(http.requests.last.path, '/resume/cover-letter');
    expect(http.requests.last.data, payload);
    await repo.polish('My own letter');
    expect(http.requests.last.path, '/resume/polish-cover-letter');
    expect(http.requests.last.data, {'coverLetterText': 'My own letter'});
  });
  test('bio SSE handles split UTF-8 chunks and requires completion', () async {
    final bytes = utf8.encode(
        'data: {"t":"chunk","v":"សួស្តី"}\n\ndata: {"t":"chunk","v":" world"}\n\ndata: {"t":"done"}\n\n');
    expect(await readBioStream(Stream.fromIterable(bytes.map((b) => [b]))),
        'សួស្តី world');
    for (final text in [
      'data: {"t":"chunk","v":"unfinished"}\n\n',
      'data: {"t":"error","v":"private upstream error"}\n\n',
      'data: not-json\n\n'
    ]) {
      await expectLater(readBioStream(Stream.value(utf8.encode(text))),
          throwsA(isA<ApiException>()));
    }
  });
  test('bio refinement posts context and reads SSE', () async {
    final http = FakeHttp((_) async => ResponseBody.fromString(
            'data: {"t":"chunk","v":"New bio"}\n\ndata: {"t":"done"}\n\n', 200,
            headers: {
              Headers.contentTypeHeader: ['text/event-stream']
            }));
    expect(
        await AiRepository(client(http)).refineBio({
          'type': 'companyBio',
          'companyName': 'Company',
          'currentText': 'Original'
        }),
        'New bio');
    expect(http.requests.single.path, '/resume/refine-bio/stream');
    expect(http.requests.single.responseType, ResponseType.stream);
    expect(http.requests.single.data['type'], 'companyBio');
  });
  test('AI daily-limit messages survive HTTP error handling', () async {
    const message =
        'Daily AI usage limit reached (100 requests/day). Your quota resets tomorrow.';
    final http = FakeHttp((_) async => jsonResponse(429, {'message': message}));
    await expectLater(
        AiRepository(client(http)).polish('draft'),
        throwsA(
            isA<ApiException>().having((e) => e.message, 'message', message)));
  });
  testWidgets('writing failures preserve the draft and refresh quota',
      (tester) async {
    var quotaReads = 0;
    final http = FakeHttp((request) async {
      if (request.path == '/ai/quota') {
        quotaReads++;
        return jsonResponse(200, quotaData());
      }
      return jsonResponse(500, {'message': 'Writing unavailable'});
    });
    final repo = AiRepository(client(http));
    await tester.pumpWidget(ProviderScope(
        overrides: [
          aiRepositoryProvider.overrideWithValue(repo),
          aiQuotaProvider.overrideWith((ref) => repo.quota()),
        ],
        child: MaterialApp(
            theme: AppTheme.light(),
            home: const AiWritingScreen(
                contextData: {'companyName': 'Company'},
                initialText: 'Keep my draft'))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Polish draft'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Polish draft'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(find.text('Keep my draft'), findsOneWidget);
    expect(find.text('Writing unavailable'), findsOneWidget);
    expect(quotaReads, greaterThanOrEqualTo(3));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'exhausted usage disables generation but keeps manual draft usable',
      (tester) async {
    final repo = AiRepository(client(
        FakeHttp((_) async => jsonResponse(200, quotaData(remaining: 0)))));
    await tester.pumpWidget(ProviderScope(
        overrides: [
          aiRepositoryProvider.overrideWithValue(repo),
          aiQuotaProvider.overrideWith((ref) => repo.quota())
        ],
        child: MaterialApp(
            theme: AppTheme.light(),
            home: const AiWritingScreen(
                contextData: {}, initialText: 'My draft'))));
    await tester.pumpAndSettle();
    final buttons =
        tester.widgetList<AppButton>(find.byType(AppButton)).toList();
    expect(
        buttons.firstWhere((b) => b.label == 'Generate cover letter').onPressed,
        isNull);
    expect(
        buttons.firstWhere((b) => b.label == 'Polish draft').onPressed, isNull);
    expect(buttons.firstWhere((b) => b.label == 'Use this draft').onPressed,
        isNotNull);
  });
  testWidgets('generated text is returned only after explicit use',
      (tester) async {
    String? accepted;
    final repo = AiRepository(client(FakeHttp((r) async => r.path == '/ai/quota'
        ? jsonResponse(200, quotaData())
        : ResponseBody.fromString(
            'data: {"t":"chunk","v":"Generated letter"}\n\ndata: {"t":"done"}\n\n',
            200,
            headers: {
                Headers.contentTypeHeader: ['text/event-stream']
              }))));
    await tester.pumpWidget(ProviderScope(
        overrides: [
          aiRepositoryProvider.overrideWithValue(repo),
          aiQuotaProvider.overrideWith((ref) => repo.quota())
        ],
        child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
                body: Builder(
                    builder: (context) => TextButton(
                        onPressed: () async {
                          accepted = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AiWritingScreen(contextData: {})));
                        },
                        child: const Text('Open writer')))))));
    await tester.tap(find.text('Open writer'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Generate cover letter'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Generate cover letter'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(accepted, isNull);
    expect(find.text('Generated letter'), findsOneWidget);
    await tester.ensureVisible(find.text('Use this draft'));
    await tester.tap(find.text('Use this draft'));
    await tester.pumpAndSettle();
    expect(accepted, 'Generated letter');
  });
}
