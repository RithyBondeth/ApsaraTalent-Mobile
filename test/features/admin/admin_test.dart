import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/admin/data/admin_repository.dart';
import 'package:apsaratalent_mobile/features/admin/presentation/admin_screen.dart';
import 'package:apsaratalent_mobile/features/admin/presentation/admin_widgets.dart';
import 'package:apsaratalent_mobile/features/admin/providers/admin_provider.dart';
import 'package:apsaratalent_mobile/features/auth/domain/entities/current_user_entity.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/admin_fixtures.dart';
import '../../support/fake_http.dart';

class _Session extends AuthSessionNotifier {
  _Session(this.role);
  final EUserRole role;
  @override
  Future<AuthSessionState> build() async => AuthSessionState.signedIn(
      CurrentUserEntity(id: 'viewer', role: role, displayName: 'Local viewer'));
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  AdminRepository repository(FakeHttp http) => AdminRepository(ApiClient(
      sessionStore: SessionStore(), baseUrl: 'http://api.test', adapter: http));
  final fixtures = {
    AdminSection.users: adminUser,
    AdminSection.jobs: adminJob,
    AdminSection.reports: adminReport,
    AdminSection.problems: adminProblem,
    AdminSection.audit: adminAudit,
  };
  final paths = {
    AdminSection.users: '/admin/users',
    AdminSection.jobs: '/admin/jobs',
    AdminSection.reports: '/admin/reports',
    AdminSection.problems: '/admin/problem-reports',
    AdminSection.audit: '/admin/audit'
  };
  for (final section in fixtures.keys) {
    test('${section.name} reads and pages the generated contract', () async {
      final http = FakeHttp((_) async => jsonResponse(
          200, adminPage([fixtures[section]!()], page: 2, total: 51)));
      final page = await repository(http).list(section,
          page: 2,
          search: '  Engineer  ',
          role: 'employee',
          status: 'pending',
          visibility: 'hidden',
          category: 'bug',
          targetUserId: 'viewer');
      expect(page.page, 2);
      expect(page.hasNext, isTrue);
      expect(page.items.single['id'], isNotEmpty);
      expect(http.requests.single.path, paths[section]);
      final query = http.requests.single.queryParameters;
      expect(query['page'], 2);
      expect(query['limit'], 25);
      expect(query.containsKey('search'),
          section == AdminSection.users || section == AdminSection.jobs);
      expect(query.containsKey('role'), section == AdminSection.users);
      expect(query.containsKey('category'), section == AdminSection.problems);
      expect(query.containsKey('targetUserId'), section == AdminSection.audit);
    });
  }
  test('empty search and filters do not reach the API', () async {
    final http = FakeHttp((_) async => jsonResponse(200, adminPage([])));
    await repository(http).list(AdminSection.users, search: '  ');
    expect(http.requests.single.queryParameters, {'page': 1, 'limit': 25});
  });
  test('user detail includes reports and history', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {
          ...adminUserDetail(),
          'reportsAgainst': [adminReport()],
          'statusHistory': [adminAudit()]
        }));
    final user = await repository(http).user('candidate-1');
    expect(user.reportsAgainst.single.details, contains('unsolicited'));
    expect(user.statusHistory.single.action, 'job_hidden');
    expect(http.requests.single.path, '/admin/users/candidate-1');
  });
  test(
      'moderation requests use DELETE body, UTC expiry and separate report routes',
      () async {
    final http =
        FakeHttp((_) async => jsonResponse(200, {'message': 'Updated'}));
    final repo = repository(http);
    final until = DateTime.now().add(const Duration(days: 7));
    await repo.updateUser('candidate-1',
        status: 'suspended',
        reason: '  Repeated abusive messages  ',
        suspendedUntil: until);
    expect(http.requests.last.method, 'PATCH');
    expect(http.requests.last.data, {
      'status': 'suspended',
      'reason': 'Repeated abusive messages',
      'suspendedUntil': until.toUtc().toIso8601String()
    });
    await repo.hideJob('job-1', '  Fraudulent job listing  ');
    expect(http.requests.last.method, 'DELETE');
    expect(http.requests.last.data, {'reason': 'Fraudulent job listing'});
    await repo.restoreJob('job-1');
    expect(http.requests.last.path, '/admin/jobs/job-1/restore');
    await repo.updateReport('report-1',
        problem: false, status: 'reviewed', note: ' Checked ');
    expect(http.requests.last.path, '/admin/reports/report-1/status');
    expect(http.requests.last.data, {'status': 'reviewed', 'note': 'Checked'});
    await repo.updateReport('problem-1', problem: true, status: 'resolved');
    expect(http.requests.last.path, '/admin/problem-reports/problem-1/status');
  });
  test('invalid moderation reasons and status/date combinations never send',
      () async {
    final http =
        FakeHttp((_) async => jsonResponse(200, {'message': 'Updated'}));
    final repo = repository(http);
    for (final reason in ['', 'short', 'x' * 501]) {
      await expectLater(
          repo.hideJob('job', reason), throwsA(isA<ApiException>()));
    }
    await expectLater(
        repo.updateUser('id',
            status: 'banned',
            reason: 'A valid reason',
            suspendedUntil: DateTime.now().add(const Duration(days: 1))),
        throwsA(isA<ApiException>()));
    await expectLater(repo.updateReport('id', problem: true, status: 'unknown'),
        throwsA(isA<ApiException>()));
    expect(http.requests, isEmpty);
  });
  testWidgets('candidate cannot open admin UI or request administrative data',
      (tester) async {
    final http = FakeHttp((_) async => jsonResponse(200, {}));
    await tester.pumpWidget(ProviderScope(overrides: [
      authSessionProvider.overrideWith(() => _Session(EUserRole.employee)),
      adminRepositoryProvider.overrideWithValue(repository(http)),
    ], child: MaterialApp(theme: AppTheme.light(), home: const AdminScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Only administrators can open this workspace.'),
        findsOneWidget);
    expect(http.requests, isEmpty);
  });
  testWidgets('admin can load overview, filter users and advance a page',
      (tester) async {
    final http = FakeHttp((r) async => jsonResponse(
        200,
        r.path.endsWith('overview')
            ? {
                'totalUsers': 51,
                'employees': 50,
                'companies': 1,
                'suspendedUsers': 0,
                'bannedUsers': 0,
                'pendingReports': 1,
                'newUsersLast7Days': 1
              }
            : adminPage([adminUser()],
                page: r.queryParameters['page'] as int, total: 51)));
    await tester.pumpWidget(ProviderScope(overrides: [
      authSessionProvider.overrideWith(() => _Session(EUserRole.admin)),
      adminRepositoryProvider.overrideWithValue(repository(http)),
    ], child: MaterialApp(theme: AppTheme.light(), home: const AdminScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Total users'), findsOneWidget);
    await tester.tap(find.text('Users'));
    await tester.pumpAndSettle();
    expect(find.text('Candidate One'), findsOneWidget);
    await tester.enterText(
        find.byType(TextField).first, 'candidate@example.test');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(
        http.requests.last.queryParameters['search'], 'candidate@example.test');
    await tester.ensureVisible(find.byTooltip('Next page'));
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(http.requests.last.queryParameters['page'], 2);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'moderation dialog requires an explanation and explicit confirmation',
      (tester) async {
    AdminDecision? result;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () async => result = await showAdminDecision(
                        context,
                        title: 'Hide posting',
                        initialStatus: 'hidden',
                        statuses: const ['hidden'],
                        reasonRequired: true),
                    child: const Text('Moderate'))))));
    await tester.tap(find.text('Moderate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(find.text('Give a reason between 10 and 500 characters.'),
        findsOneWidget);
    await tester.enterText(
        find.byType(TextField), 'A detailed moderation reason');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(result?.note, 'A detailed moderation reason');
  });
}
