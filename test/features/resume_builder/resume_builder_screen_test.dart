import 'package:apsaratalent_mobile/features/ai/data/ai_repository.dart';
import 'package:apsaratalent_mobile/features/ai/presentation/ai_quota.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/providers/profile_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_state.dart';
import 'package:apsaratalent_mobile/features/resume_builder/data/resume_repository.dart';
import 'package:apsaratalent_mobile/features/resume_builder/presentation/screens/resume_builder_screen.dart';
import '../../support/fake_http.dart';

class CandidateProfile extends ProfileNotifier {
  @override
  Future<UserProfile?> build() async => const EmployeeProfile(
      id: 'e',
      fullName: 'Test Candidate',
      email: 'test@example.com',
      description: 'Original summary',
      skills: ['Flutter']);
}

class TestSession extends AuthSessionNotifier {
  @override
  Future<AuthSessionState> build() async =>
      const AuthSessionState.signedIn(null);
}

void main() {
  testWidgets(
      'loads real profile, saves section edits, and retains them after AI failure',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final http = FakeHttp((request) async => request.path == '/ai/quota'
        ? jsonResponse(200, {
            'daily': {'remaining': 10, 'limit': 100},
            'actions': {
              'cvGeneration': {'remaining': 3, 'limit': 3}
            },
            'resetsAt':
                DateTime.now().add(const Duration(days: 1)).toIso8601String()
          })
        : request.path == '/resume/template/all'
            ? jsonResponse(200, [
                {'templateKey': 'modern', 'title': 'Modern'}
              ])
            : jsonResponse(429, {'message': 'AI quota exhausted'}));
    await tester.pumpWidget(ProviderScope(
        overrides: [
          aiRepositoryProvider.overrideWithValue(AiRepository(ApiClient(
              sessionStore: SessionStore(),
              baseUrl: 'http://api.test',
              adapter: http))),
          profileProvider.overrideWith(CandidateProfile.new),
          authSessionProvider.overrideWith(TestSession.new),
          resumeRepositoryProvider.overrideWithValue(ResumeRepository(ApiClient(
              sessionStore: SessionStore(),
              baseUrl: 'http://api.test',
              adapter: http))),
        ],
        child: MaterialApp(
            theme: AppTheme.light(), home: const ResumeBuilderScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Test Candidate'), findsOneWidget);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Edited summary');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Edited summary'), findsOneWidget);
    await tester.ensureVisible(find.text('Generate AI draft'));
    await tester.tap(find.text('Generate AI draft'));
    await tester.pumpAndSettle();
    expect(
        http.requests
            .firstWhere((r) => r.path == '/resume/generate')
            .data['summary'],
        'Edited summary');
    expect(find.text('Edited summary'), findsOneWidget);
    expect(find.text('Too many attempts. Please wait a minute and try again.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
