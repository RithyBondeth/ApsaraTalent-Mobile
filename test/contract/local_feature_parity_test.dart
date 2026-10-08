import 'dart:io';
import 'package:apsaratalent_mobile/features/search/data/repositories/search_repository_impl.dart';
import 'package:apsaratalent_mobile/features/saved_search/data/repositories/saved_search_repository_impl.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/auth_cookies.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/admin/data/admin_repository.dart';
import 'package:apsaratalent_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = 'http://127.0.0.1:13000';
  final enabled = Platform.environment['LOCAL_PARITY_TEST'] == '1';
  test('real local dashboard/admin workflows and role boundary', () async {
    FlutterSecureStorage.setMockInitialValues({});
    Future<ApiClient> login(String email) async {
      final store = SessionStore();
      final client = ApiClient(sessionStore: store, baseUrl: base);
      final response = await client.post('/auth/login',
          data: {'identifier': email, 'password': 'LocalTest!12345'});
      final tokens = AuthCookies.read(response.headers);
      expect(tokens, isNotNull);
      await store.save(tokens!, remember: false);
      return client;
    }

    final candidate = await login('candidate@local.test');
    final company = await login('employer@local.test');
    for (final pair in [
      (candidate, FeedViewerRole.employee),
      (company, FeedViewerRole.company)
    ]) {
      final user = (await pair.$1.get('/user/current-user')).data as Map;
      final profile = user[pair.$2.name] as Map;
      final stats = await DashboardRepository(pair.$1)
          .fetch(FeedViewer(role: pair.$2, profileId: profile['id'] as String));
      expect(stats.weeklyActivity.length, 7);
      expect(stats.totalMatches, greaterThanOrEqualTo(0));
    }
    final filters = {
      'location': 'Phnom Penh',
      'workMode': 'hybrid',
      'salaryMin': 500,
      'companySizeMin': 5,
      'companySizeMax': 50,
      'sortBy': 'createdAt',
      'sortOrder': 'DESC'
    };
    final search = SearchRepositoryImpl(candidate);
    final matchingJobs = await search.searchJobs(keyword: '', filters: filters);
    expect(
        matchingJobs.items.any((job) => job.title == 'Local Software Engineer'),
        isTrue);
    final keywordJobs =
        await search.searchJobs(keyword: 'Software', filters: filters);
    expect(
        keywordJobs.items.any((job) => job.title == 'Local Software Engineer'),
        isTrue);
    final talent =
        await SearchRepositoryImpl(company).searchTalent(keyword: '', filters: {
      'skills': ['TypeScript'],
      'location': 'Phnom Penh',
      'sortBy': 'yearsOfExperience',
      'sortOrder': 'DESC'
    });
    expect(talent.items, isNotEmpty);
    final savedRepository = SavedSearchRepositoryImpl(candidate);
    final saved = await savedRepository.create(
        name: 'Disposable shared filters test', keyword: '', filters: filters);
    try {
      final fetched = (await savedRepository.fetchAll())
          .firstWhere((item) => item.id == saved.id);
      expect(fetched.filters['salaryMin'], 500);
      expect(fetched.filters['workMode'], 'hybrid');
      expect((await savedRepository.preview(saved.id)).total,
          greaterThanOrEqualTo(1));
    } finally {
      await savedRepository.remove(saved.id);
    }
    await expectLater(
        AdminRepository(candidate).overview(),
        throwsA(isA<ApiException>()
            .having((error) => error.statusCode, 'non-admin status', 403)));
    final admin = AdminRepository(await login('admin@local.test'));
    final overview = await admin.overview();
    expect(overview['totalUsers'], greaterThanOrEqualTo(4));
    for (final section in [
      AdminSection.users,
      AdminSection.jobs,
      AdminSection.reports,
      AdminSection.problems,
      AdminSection.audit
    ]) {
      final page = await admin.list(section);
      expect(page.page, 1);
    }
    final probe = (await admin.list(AdminSection.users,
            search: 'moderation-probe@local.test'))
        .items
        .single;
    final id = probe['id'] as String;
    final detail = await admin.user(id);
    expect(detail.status, 'active');
    try {
      await admin.updateUser(id,
          status: 'suspended',
          reason: 'Disposable local parity test suspension',
          suspendedUntil: DateTime.now().add(const Duration(days: 1)));
      expect((await admin.user(id)).status, 'suspended');
    } finally {
      await admin.updateUser(id,
          status: 'active',
          reason: 'Restore the disposable local parity fixture');
    }
    expect((await admin.user(id)).statusHistory, isNotEmpty);
    final userReportNote =
        'Disposable user report parity probe ${DateTime.now().microsecondsSinceEpoch}';
    await candidate.post('/user/moderation/report',
        data: {'reportedId': id, 'reason': 'spam', 'details': userReportNote});
    final userReports =
        await admin.list(AdminSection.reports, status: 'pending');
    final userReport =
        userReports.items.firstWhere((r) => r['details'] == userReportNote);
    await admin.updateReport(userReport['id'] as String,
        problem: false, status: 'resolved', note: 'Local triage verified.');
    final jobs = await admin.list(AdminSection.jobs,
        search: 'Local Software Engineer', visibility: 'all');
    final jobId = jobs.items.single['id'] as String;
    try {
      await admin.hideJob(jobId, 'Disposable local parity test takedown');
      final hidden = await admin.list(AdminSection.jobs,
          search: 'Local Software Engineer', visibility: 'hidden');
      expect(hidden.items.single['hiddenReason'], contains('parity test'));
    } finally {
      await admin.restoreJob(jobId);
    }
    final description =
        'Disposable local support parity probe ${DateTime.now().microsecondsSinceEpoch}';
    await candidate.post('/user/support/report-problem', data: {
      'category': 'bug',
      'details': description,
      'pageUrl': '/local-parity-test',
      'userAgent': 'Local Dart SDK'
    });
    final reports = await admin.list(AdminSection.problems, category: 'bug');
    final problem =
        reports.items.firstWhere((r) => r['details'] == description);
    await admin.updateReport(problem['id'] as String,
        problem: true,
        status: 'resolved',
        note: 'Verified through the local Dart client.');
    expect(
        (await admin.list(AdminSection.problems, status: 'resolved'))
            .items
            .any((r) => r['id'] == problem['id']),
        isTrue);
  },
      skip: !enabled
          ? 'Run LOCAL_PARITY_TEST=1 with the disposable local-test stack.'
          : false);
}
