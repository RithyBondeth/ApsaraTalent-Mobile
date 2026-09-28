import 'package:apsaratalent_mobile/core/constants/apis/employer_workflow_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/utils/json_parse.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/employer_workflow.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/job_application.dart';

class EmployerWorkflowRepository {
  EmployerWorkflowRepository(this._client);

  final ApiClient _client;

  Future<EmployerAnalytics> analytics() => _guard(
        'Could not load employer analytics.',
        () async => EmployerAnalytics.fromJson(
          _map((await _client.get(apiEmployerAnalytics)).data),
        ),
      );

  Future<JobPipeline> pipeline(String jobId, String companyId) => _guard(
        'Could not load the applicant pipeline.',
        () async => JobPipeline.fromJson(
          _map((await _client.get(apiJobPipeline(jobId, companyId))).data),
        ),
      );

  Future<JobApplication> updateStatus(
    String applicationId,
    ApplicationStatus status, {
    String? rejectionReason,
  }) =>
      _guard(
        'Could not update the application.',
        () async => JobApplication.fromJson(
          _map((await _client.patch(apiUpdateApplicationStatus, data: {
            'applicationId': applicationId,
            'status': status.name,
            if (rejectionReason != null && rejectionReason.trim().isNotEmpty)
              'rejectionReason': rejectionReason.trim(),
          }))
              .data),
        ),
      );

  Future<BulkUpdateResult> bulkUpdate(
    List<String> applicationIds,
    ApplicationStatus status, {
    String? rejectionReason,
  }) =>
      _guard('Could not update the selected applications.', () async {
        final data = _map((await _client.patch(
          apiBulkUpdateApplicationStatus,
          data: {
            'applicationIds': applicationIds,
            'status': status.name,
            if (rejectionReason != null && rejectionReason.trim().isNotEmpty)
              'rejectionReason': rejectionReason.trim(),
          },
        ))
            .data);
        return BulkUpdateResult(
          updated: jsonInt(data['updatedCount']) ?? 0,
          failed: jsonInt(data['failedCount']) ?? 0,
        );
      });

  Future<List<ApplicationNote>> notes(String applicationId) => _guard(
        'Could not load application notes.',
        () async => jsonMaps(
          (await _client.get(apiApplicationNotes(applicationId))).data,
        ).map(ApplicationNote.fromJson).toList(),
      );

  Future<ApplicationNote> addNote(String applicationId, String body) => _guard(
        'Could not save the note.',
        () async => ApplicationNote.fromJson(
          _map((await _client.post(
            apiApplicationNotes(applicationId),
            data: {'body': body.trim()},
          ))
              .data),
        ),
      );

  Future<void> deleteNote(String applicationId, String noteId) => _guard(
        'Could not delete the note.',
        () async {
          await _client.delete(apiApplicationNote(applicationId, noteId));
        },
      );

  Future<List<ApplicationHistoryEntry>> history(String applicationId) => _guard(
        'Could not load application history.',
        () async => jsonMaps(
          (await _client.get(apiApplicationHistory(applicationId))).data,
        ).map(ApplicationHistoryEntry.fromJson).toList(),
      );

  Future<List<Interview>> interviews(String companyId) => _guard(
        'Could not load interviews.',
        () async => jsonMaps(
          (await _client.get(apiCompanyInterviews(companyId))).data,
        ).map(Interview.fromJson).toList(),
      );

  Future<List<Interview>> employeeInterviews(String employeeId) => _guard(
        'Could not load your interviews.',
        () async => jsonMaps(
          (await _client.get(apiEmployeeInterviews(employeeId))).data,
        ).map(Interview.fromJson).toList(),
      );

  Future<Interview> createInterview({
    required String employeeId,
    required String companyId,
    required String applicationId,
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,
    String? description,
    String? location,
    String? meetingLink,
  }) =>
      _guard(
        'Could not schedule the interview.',
        () async => Interview.fromJson(
          _map((await _client.post(apiInterview, data: {
            'employeeId': employeeId,
            'companyId': companyId,
            'applicationId': applicationId,
            'title': title.trim(),
            'scheduledAt': scheduledAt.toUtc().toIso8601String(),
            'durationMinutes': durationMinutes,
            if (description != null && description.trim().isNotEmpty)
              'description': description.trim(),
            if (location != null && location.trim().isNotEmpty)
              'location': location.trim(),
            if (meetingLink != null && meetingLink.trim().isNotEmpty)
              'meetingLink': meetingLink.trim(),
          }))
              .data),
        ),
      );

  Future<Interview> updateInterviewStatus(
          String interviewId, InterviewStatus status) =>
      _guard(
        'Could not update the interview.',
        () async => Interview.fromJson(
          _map((await _client.patch(apiInterviewStatus, data: {
            'interviewId': interviewId,
            'status': status.name,
          }))
              .data),
        ),
      );

  Map<String, dynamic> _map(dynamic data) {
    if (data is! Map) {
      throw ApiException(message: 'The server response was invalid.');
    }
    return data.cast<String, dynamic>();
  }

  Future<T> _guard<T>(String fallback, Future<T> Function() work) async {
    try {
      return await work();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: fallback);
    }
  }
}
