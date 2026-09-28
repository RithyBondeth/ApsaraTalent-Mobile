import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/application/data/repositories/employer_workflow_repository.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/employer_workflow.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/job_application.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  EmployerWorkflowRepository repositoryFor(FakeHttp http) =>
      EmployerWorkflowRepository(ApiClient(
        sessionStore: SessionStore(),
        baseUrl: 'http://api.test',
        adapter: http,
      ));

  test('reads employer analytics and the complete funnel', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {
          'openPositions': 3,
          'activePipeline': 8,
          'hired30d': 2,
          'rejected30d': 4,
          'applicationsDelta': {'current': 12, 'previous': 9, 'delta': 3},
          'medianDaysToFirstMove': 1.5,
          'funnel': [
            {'status': 'pending', 'count': 5},
            {'status': 'hired', 'count': 2},
          ],
          'topJobs': [
            {
              'jobId': 'j1',
              'title': 'Engineer',
              'totalApplicants': 9,
              'activePipeline': 5,
              'hired': 1,
              'rejected': 3,
            },
          ],
        }));

    final result = await repositoryFor(http).analytics();

    expect(http.requests.single.path, '/job/employer-analytics');
    expect(result.activePipeline, 8);
    expect(result.applicationsDelta, 3);
    expect(result.funnel.last.status, ApplicationStatus.hired);
    expect(result.topJobs.single.totalApplicants, 9);
  });

  test('reads a job pipeline with applicant identity and match score',
      () async {
    final http = FakeHttp((_) async => jsonResponse(200, {
          'jobId': 'j1',
          'jobTitle': 'Engineer',
          'totalCount': 1,
          'columns': [
            {
              'status': 'pending',
              'count': 1,
              'applications': [
                {
                  'id': 'a1',
                  'status': 'pending',
                  'employeeId': 'e1',
                  'employeeName': 'Sokha Chan',
                  'matchScore': 87,
                },
              ],
            },
          ],
        }));

    final result = await repositoryFor(http).pipeline('j1', 'c1');

    expect(http.requests.single.path,
        '/job/application/pipeline/job/j1/company/c1');
    expect(
        result.columns.single.applications.single.employeeName, 'Sokha Chan');
    expect(result.columns.single.applications.single.matchScore, 87);
  });

  test('updates one stage with an optional rejection reason', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {
          'id': 'a1',
          'status': 'rejected',
          'rejectionReason': 'Experience mismatch',
        }));

    final result = await repositoryFor(http).updateStatus(
      'a1',
      ApplicationStatus.rejected,
      rejectionReason: 'Experience mismatch',
    );

    expect(http.requests.single.method, 'PATCH');
    expect(http.requests.single.path, '/job/application/status');
    expect(http.requests.single.data, {
      'applicationId': 'a1',
      'status': 'rejected',
      'rejectionReason': 'Experience mismatch',
    });
    expect(result.status, ApplicationStatus.rejected);
  });

  test('bulk status returns partial success counts', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {
          'results': [],
          'updatedCount': 2,
          'failedCount': 1,
        }));

    final result = await repositoryFor(http).bulkUpdate(
      ['a1', 'a2', 'a3'],
      ApplicationStatus.shortlisted,
    );

    expect(http.requests.single.path, '/job/application/bulk-status');
    expect(http.requests.single.data['applicationIds'], ['a1', 'a2', 'a3']);
    expect(result.updated, 2);
    expect(result.failed, 1);
  });

  test('creates notes and schedules an application interview', () async {
    final http = FakeHttp((request) async {
      if (request.path.endsWith('/notes')) {
        return jsonResponse(201, {
          'id': 'n1',
          'body': 'Strong portfolio',
          'authorName': 'Recruiter',
        });
      }
      return jsonResponse(201, {
        'id': 'i1',
        'title': 'Technical interview',
        'status': 'pending',
        'scheduledAt': '2026-10-01T03:00:00.000Z',
        'durationMinutes': 60,
        'applicationId': 'a1',
        'employee': {'id': 'e1', 'firstname': 'Sokha', 'lastname': 'Chan'},
        'company': {'id': 'c1', 'name': 'Apsara'},
      });
    });
    final repository = repositoryFor(http);

    final note = await repository.addNote('a1', 'Strong portfolio');
    final interview = await repository.createInterview(
      employeeId: 'e1',
      companyId: 'c1',
      applicationId: 'a1',
      title: 'Technical interview',
      scheduledAt: DateTime.utc(2026, 10, 1, 3),
      durationMinutes: 60,
    );

    expect(note.authorName, 'Recruiter');
    expect(http.requests.first.path, '/job/application/a1/notes');
    expect(http.requests.last.path, '/match/interview');
    expect(http.requests.last.data['applicationId'], 'a1');
    expect(http.requests.last.data.containsKey('timezone'), isFalse);
    expect(interview.employeeName, 'Sokha Chan');
  });

  test('reads notes, history, interviews and updates interview status',
      () async {
    final http = FakeHttp((request) async {
      if (request.path.endsWith('/notes')) {
        return jsonResponse(200, [
          {'id': 'n1', 'body': 'Call references'},
        ]);
      }
      if (request.path.endsWith('/history')) {
        return jsonResponse(200, [
          {'id': 'h1', 'from': 'pending', 'to': 'shortlisted'},
        ]);
      }
      if (request.path.contains('/company/')) {
        return jsonResponse(200, [
          {
            'id': 'i1',
            'title': 'Interview',
            'status': 'accepted',
            'scheduledAt': '2026-10-01T03:00:00.000Z',
          },
        ]);
      }
      return jsonResponse(200, {
        'id': 'i1',
        'title': 'Interview',
        'status': 'completed',
        'scheduledAt': '2026-10-01T03:00:00.000Z',
      });
    });
    final repository = repositoryFor(http);

    expect((await repository.notes('a1')).single.body, 'Call references');
    expect((await repository.history('a1')).single.to,
        ApplicationStatus.shortlisted);
    expect((await repository.interviews('c1')).single.status,
        InterviewStatus.accepted);
    expect(
      (await repository.updateInterviewStatus('i1', InterviewStatus.completed))
          .status,
      InterviewStatus.completed,
    );
  });
}
