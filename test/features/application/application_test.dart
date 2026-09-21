import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/application/data/repositories/application_repository_impl.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/job_application.dart';
import 'package:apsaratalent_mobile/features/application/domain/repositories/application_repository.dart';
import 'package:apsaratalent_mobile/features/application/providers/application_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

/// A real row from `GET /job/application/mine`. Note what is absent: the
/// payload names the job but never the company.
Map<String, dynamic> row(
  String id, {
  String status = 'pending',
  String jobId = 'j1',
}) =>
    {
      'id': id,
      'status': status,
      'coverLetterNote': 'Keen to help scale the frontend.',
      'rejectionReason': null,
      'reviewedAt': null,
      'statusChangedAt': null,
      'appliedAt': '2026-09-20T08:48:45.717Z',
      'jobId': jobId,
      'jobTitle': 'React Developer',
    };

JobApplication app(String id, {String status = 'pending', String jobId = 'j1'}) =>
    JobApplication.fromJson(row(id, status: status, jobId: jobId));

class FakeApplicationRepository implements ApplicationRepository {
  // One application per (employee, job) — the API enforces it, so the fixture
  // must not pretend otherwise.
  List<JobApplication> items = [
    app('a1'),
    app('a2', status: 'rejected', jobId: 'j2'),
  ];
  bool fail = false;
  final List<String> withdrawn = [];
  final List<String> applied = [];

  @override
  Future<List<JobApplication>> fetchMine() async => items;

  /// Mirrors the API: a withdrawn application is revived rather than a second
  /// one inserted, and applying while one is active is refused.
  @override
  Future<JobApplication> apply(String jobId, {String? coverLetterNote}) async {
    applied.add(jobId);
    if (fail) throw ApiException(message: 'apply failed');
    final existing =
        items.where((a) => a.jobId == jobId).cast<JobApplication?>().firstOrNull;
    if (existing != null && existing.status != ApplicationStatus.withdrawn) {
      throw ApiException(
        message: 'You have already applied to this job',
        statusCode: 409,
      );
    }
    final revived = (existing ?? app('new-$jobId', jobId: jobId))
        .copyWith(status: ApplicationStatus.pending);
    items = [
      for (final a in items)
        if (a.jobId == jobId) revived else a,
      if (existing == null) revived,
    ];
    return revived;
  }

  @override
  Future<void> withdraw(String applicationId) async {
    if (fail) throw ApiException(message: 'withdraw failed');
    withdrawn.add(applicationId);
    // The API keeps the row and moves it to withdrawn; so does this, or a
    // later apply would wrongly look like a duplicate.
    items = [
      for (final a in items)
        if (a.id == applicationId)
          a.copyWith(status: ApplicationStatus.withdrawn)
        else
          a,
    ];
  }
}

void main() {
  group('parsing', () {
    test('reads a row, including the fields that are usually null', () {
      final parsed = JobApplication.fromJson(row('a1'));

      expect(parsed.id, 'a1');
      expect(parsed.status, ApplicationStatus.pending);
      expect(parsed.jobTitle, 'React Developer');
      expect(parsed.coverLetterNote, 'Keen to help scale the frontend.');
      // Null until the company first opens its applicant list.
      expect(parsed.reviewedAt, isNull);
      // Null while the application has never left pending.
      expect(parsed.statusChangedAt, isNull);
    });

    test('an unknown status renders rather than vanishing', () {
      final parsed = JobApplication.fromJson(row('a1', status: 'ghosted'));

      expect(parsed.status, ApplicationStatus.unknown);
      expect(parsed.status.label, 'Unknown');
    });

    test('the legacy reviewed status still parses', () {
      // Postgres cannot drop an enum label, so rows may still carry it even
      // though nothing can transition into it any more.
      expect(
        JobApplication.fromJson(row('a1', status: 'reviewed')).status,
        ApplicationStatus.reviewed,
      );
    });
  });

  group('what can be withdrawn', () {
    test('only an application still in play', () {
      expect(ApplicationStatus.pending.canWithdraw, isTrue);
      expect(ApplicationStatus.shortlisted.canWithdraw, isTrue);
      expect(ApplicationStatus.interviewing.canWithdraw, isTrue);
      expect(ApplicationStatus.offered.canWithdraw, isTrue);
    });

    test('not one that is already finished', () {
      // Withdrawing from a rejection or from a job already taken is not a
      // thing to offer.
      expect(ApplicationStatus.rejected.canWithdraw, isFalse);
      expect(ApplicationStatus.hired.canWithdraw, isFalse);
      expect(ApplicationStatus.withdrawn.canWithdraw, isFalse);
    });
  });

  group('repository', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    ApplicationRepositoryImpl repositoryFor(FakeHttp http) =>
        ApplicationRepositoryImpl(
          ApiClient(
            sessionStore: SessionStore(),
            baseUrl: 'http://api.test',
            adapter: http,
          ),
        );

    test('reads the viewer own applications', () async {
      final http = FakeHttp((_) async => jsonResponse(200, [row('a1')]));

      final items = await repositoryFor(http).fetchMine();

      expect(http.requests.single.path, '/job/application/mine');
      expect(items.single.jobTitle, 'React Developer');
    });

    test('withdrawing deletes the application route', () async {
      final http = FakeHttp(
        (_) async => jsonResponse(200, {'message': 'Withdrawn'}),
      );

      await repositoryFor(http).withdraw('a1');

      expect(http.requests.single.method, 'DELETE');
      expect(http.requests.single.path, '/job/application/a1');
    });

    test('a body that is not a list reads as empty, not a crash', () async {
      final http = FakeHttp((_) async => jsonResponse(200, {'oops': true}));

      expect(await repositoryFor(http).fetchMine(), isEmpty);
    });
  });

  group('notifier', () {
    late FakeApplicationRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeApplicationRepository();
      container = ProviderContainer(overrides: [
        applicationRepositoryProvider.overrideWithValue(repository),
      ]);
      addTearDown(container.dispose);
    });

    test('counts the ones still open, not every row', () async {
      final state = await container.read(applicationsProvider.future);

      expect(state.items, hasLength(2));
      // a2 is rejected, so one is still in play.
      expect(state.open, 1);
    });

    test('withdrawing marks the row rather than removing it', () async {
      final state = await container.read(applicationsProvider.future);

      await container
          .read(applicationsProvider.notifier)
          .withdraw(state.items.first);

      expect(repository.withdrawn, ['a1']);
      final latest = container.read(applicationsProvider).value!;
      // The record of having applied is kept, which is what the API does.
      expect(latest.items, hasLength(2));
      expect(latest.items.first.status, ApplicationStatus.withdrawn);
      expect(latest.open, 0);
    });

    test('a failed withdrawal puts the old status back', () async {
      final state = await container.read(applicationsProvider.future);
      repository.fail = true;

      await expectLater(
        container
            .read(applicationsProvider.notifier)
            .withdraw(state.items.first),
        throwsA(isA<ApiException>()),
      );

      final latest = container.read(applicationsProvider).value!;
      expect(latest.items.first.status, ApplicationStatus.pending);
      expect(latest.isPending('a1'), isFalse);
    });

    test('applying while one is active is refused with the API message',
        () async {
      await container.read(applicationsProvider.future);

      // a1 is pending on job j1.
      await expectLater(
        container.read(applicationsProvider.notifier).apply('j1'),
        throwsA(isA<ApiException>().having(
          (e) => e.message,
          'message',
          'You have already applied to this job',
        )),
      );
    });

    test('applying after a withdrawal revives the same row', () async {
      // Verified against the API: the id is unchanged, the status returns to
      // pending, and there is still exactly one application for that job.
      final state = await container.read(applicationsProvider.future);
      await container
          .read(applicationsProvider.notifier)
          .withdraw(state.items.first);

      final revived =
          await container.read(applicationsProvider.notifier).apply('j1');

      expect(revived.id, 'a1');
      expect(revived.status, ApplicationStatus.pending);
      final latest = container.read(applicationsProvider).value!;
      expect(latest.items.where((a) => a.jobId == 'j1'), hasLength(1));
    });

    test('an active application is visible to the job detail screen',
        () async {
      await container.read(applicationsProvider.future);
      final notifier = container.read(applicationsProvider.notifier);

      expect(notifier.hasActiveApplicationFor('j1'), isTrue);
      expect(notifier.hasActiveApplicationFor('j-unknown'), isFalse);
    });

    test('a withdrawn application does not count as active', () async {
      // It can be revived by applying again, so the button must not say
      // "Applied".
      final state = await container.read(applicationsProvider.future);
      await container
          .read(applicationsProvider.notifier)
          .withdraw(state.items.first);

      expect(
        container
            .read(applicationsProvider.notifier)
            .hasActiveApplicationFor('j1'),
        isFalse,
      );
    });

    test('a finished application cannot be withdrawn', () async {
      final state = await container.read(applicationsProvider.future);

      // a2 is rejected; the screen hides the button, and the notifier
      // refuses as well rather than trusting the screen.
      await container
          .read(applicationsProvider.notifier)
          .withdraw(state.items[1]);

      expect(repository.withdrawn, isEmpty);
    });
  });
}
