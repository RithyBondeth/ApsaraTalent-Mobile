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
Map<String, dynamic> row(String id, {String status = 'pending'}) => {
      'id': id,
      'status': status,
      'coverLetterNote': 'Keen to help scale the frontend.',
      'rejectionReason': null,
      'reviewedAt': null,
      'statusChangedAt': null,
      'appliedAt': '2026-09-20T08:48:45.717Z',
      'jobId': 'j1',
      'jobTitle': 'React Developer',
    };

JobApplication app(String id, {String status = 'pending'}) =>
    JobApplication.fromJson(row(id, status: status));

class FakeApplicationRepository implements ApplicationRepository {
  List<JobApplication> items = [app('a1'), app('a2', status: 'rejected')];
  bool fail = false;
  final List<String> withdrawn = [];

  @override
  Future<List<JobApplication>> fetchMine() async => items;

  @override
  Future<void> withdraw(String applicationId) async {
    if (fail) throw ApiException(message: 'withdraw failed');
    withdrawn.add(applicationId);
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
