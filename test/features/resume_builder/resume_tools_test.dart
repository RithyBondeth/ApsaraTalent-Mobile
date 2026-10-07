import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_state.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/ai/data/ai_repository.dart';
import 'package:apsaratalent_mobile/features/ai/presentation/ai_quota.dart';
import 'package:apsaratalent_mobile/features/ai/presentation/ai_writing_screen.dart';
import 'package:apsaratalent_mobile/features/resume_builder/data/resume_repository.dart';
import 'package:apsaratalent_mobile/features/resume_builder/presentation/screens/resume_builder_screen.dart';
import 'package:apsaratalent_mobile/features/resume_builder/presentation/screens/resume_ai_tools_screen.dart';
import '../../support/fake_http.dart';

class TestSession extends AuthSessionNotifier {
  @override
  Future<AuthSessionState> build() async =>
      const AuthSessionState.signedIn(null);
}

void main() {
  testWidgets(
      'optimization leaves the draft unchanged until reviewed changes are applied',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final draft = <String, dynamic>{
      'personalInfo': {'fullName': 'Candidate', 'email': 'me@example.com'},
      'skills': ['Dart'],
      'experience': [],
      'template': 'modern',
      'summary': 'Original'
    };
    final http = FakeHttp((request) async {
      if (request.path == '/resume/optimize') {
        return jsonResponse(200, {
          'overallFeedback': 'Clear resume',
          'suggestedSummary': 'Improved',
          'suggestedSkills': ['Flutter'],
          'experienceSuggestions': []
        });
      }
      return jsonResponse(200, {
        'daily': {'remaining': 10, 'limit': 100},
        'actions': {
          'cvGeneration': {'remaining': 3, 'limit': 3}
        },
        'resetsAt':
            DateTime.now().add(const Duration(days: 1)).toIso8601String()
      });
    });
    final client = ApiClient(
        sessionStore: SessionStore(),
        baseUrl: 'http://api.test',
        adapter: http);
    Map<String, dynamic>? applied;
    await tester.pumpWidget(ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(TestSession.new),
          resumeRepositoryProvider.overrideWithValue(ResumeRepository(client)),
          aiRepositoryProvider.overrideWithValue(AiRepository(client))
        ],
        child: MaterialApp(
            theme: AppTheme.light(),
            home: Builder(
                builder: (context) => Scaffold(
                    body: TextButton(
                        onPressed: () async {
                          applied = await Navigator.push(
                              context,
                              MaterialPageRoute<Map<String, dynamic>>(
                                  builder: (_) =>
                                      ResumeAiToolsScreen(draft: draft)));
                        },
                        child: const Text('Open')))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate suggestions'));
    await tester.pumpAndSettle();
    expect(draft['summary'], 'Original');
    expect(applied, isNull);
    await tester.ensureVisible(find.text('Apply reviewed changes'));
    await tester.tap(find.text('Apply reviewed changes'));
    await tester.pumpAndSettle();
    expect(applied!['summary'], 'Improved');
    expect(applied!['skills'], ['Dart', 'Flutter']);
    expect(draft['summary'], 'Original');
  });
  testWidgets('PDF export uses the edited cover letter without an AI request',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final pdf = utf8.encode('%PDF-1.4\nfixture');
    final http = FakeHttp((request) async {
      if (request.path == '/resume/cover-letter-pdf') {
        return jsonResponse(
            200, {'mimeType': 'application/pdf', 'data': base64Encode(pdf)});
      }
      return jsonResponse(200, {
        'daily': {'remaining': 0, 'limit': 100},
        'actions': {
          'cvGeneration': {'remaining': 0, 'limit': 3}
        },
        'resetsAt':
            DateTime.now().add(const Duration(days: 1)).toIso8601String()
      });
    });
    final client = ApiClient(
        sessionStore: SessionStore(),
        baseUrl: 'http://api.test',
        adapter: http);
    final opened = <List<int>>[];
    await tester.pumpWidget(ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(TestSession.new),
          resumeRepositoryProvider.overrideWithValue(ResumeRepository(client)),
          aiRepositoryProvider.overrideWithValue(AiRepository(client)),
          resumePdfPreviewProvider.overrideWithValue((bytes) async {
            opened.add(bytes);
          })
        ],
        child: MaterialApp(
            theme: AppTheme.light(),
            home: const AiWritingScreen(contextData: {
              'employeeName': 'Candidate',
              'companyName': 'Company'
            }, initialText: 'Initial draft'))));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Reviewed letter');
    await tester.ensureVisible(find.text('Export cover-letter PDF'));
    await tester.tap(find.text('Export cover-letter PDF'));
    await tester.pumpAndSettle();
    expect(opened.single, pdf);
    final request =
        http.requests.singleWhere((r) => r.path == '/resume/cover-letter-pdf');
    expect(request.data['coverLetterText'], 'Reviewed letter');
    expect(http.requests.any((r) => r.path == '/resume/cover-letter'), false);
  });
}
