import 'package:apsaratalent_mobile/core/utils/json_parse.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/job_application.dart';

class PipelineColumn {
  const PipelineColumn({
    required this.status,
    required this.count,
    required this.applications,
  });

  factory PipelineColumn.fromJson(Map<String, dynamic> json) => PipelineColumn(
        status: ApplicationStatus.fromKey(jsonText(json['status'])),
        count: jsonInt(json['count']) ?? 0,
        applications: jsonMaps(json['applications'])
            .map(JobApplication.fromJson)
            .toList(),
      );

  final ApplicationStatus status;
  final int count;
  final List<JobApplication> applications;
}

class JobPipeline {
  const JobPipeline({
    required this.jobId,
    required this.jobTitle,
    required this.columns,
    required this.totalCount,
  });

  factory JobPipeline.fromJson(Map<String, dynamic> json) => JobPipeline(
        jobId: '${json['jobId']}',
        jobTitle: jsonText(json['jobTitle']) ?? 'Role',
        columns:
            jsonMaps(json['columns']).map(PipelineColumn.fromJson).toList(),
        totalCount: jsonInt(json['totalCount']) ?? 0,
      );

  final String jobId;
  final String jobTitle;
  final List<PipelineColumn> columns;
  final int totalCount;
}

class ApplicationNote {
  const ApplicationNote({
    required this.id,
    required this.body,
    this.authorName,
    this.createdAt,
  });

  factory ApplicationNote.fromJson(Map<String, dynamic> json) =>
      ApplicationNote(
        id: '${json['id']}',
        body: jsonText(json['body']) ?? '',
        authorName: jsonText(json['authorName']),
        createdAt: DateTime.tryParse(jsonText(json['createdAt']) ?? ''),
      );

  final String id;
  final String body;
  final String? authorName;
  final DateTime? createdAt;
}

class ApplicationHistoryEntry {
  const ApplicationHistoryEntry({
    required this.id,
    required this.to,
    this.from,
    this.note,
    this.actorName,
    this.createdAt,
  });

  factory ApplicationHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ApplicationHistoryEntry(
        id: '${json['id']}',
        from: jsonText(json['from']) == null
            ? null
            : ApplicationStatus.fromKey(jsonText(json['from'])),
        to: ApplicationStatus.fromKey(jsonText(json['to'])),
        note: jsonText(json['note']),
        actorName: jsonText(json['actorName']),
        createdAt: DateTime.tryParse(jsonText(json['createdAt']) ?? ''),
      );

  final String id;
  final ApplicationStatus? from;
  final ApplicationStatus to;
  final String? note;
  final String? actorName;
  final DateTime? createdAt;
}

enum InterviewStatus {
  pending,
  accepted,
  declined,
  cancelled,
  completed,
  unknown;

  static InterviewStatus fromKey(String? key) =>
      InterviewStatus.values.firstWhere((status) => status.name == key,
          orElse: () => InterviewStatus.unknown);
}

class Interview {
  const Interview({
    required this.id,
    required this.title,
    required this.status,
    required this.scheduledAt,
    this.description,
    this.timezone,
    this.durationMinutes = 60,
    this.location,
    this.meetingLink,
    this.applicationId,
    this.employeeId,
    this.employeeName,
  });

  factory Interview.fromJson(Map<String, dynamic> json) {
    final employee = json['employee'];
    final employeeMap = employee is Map ? employee : const {};
    final first = jsonText(employeeMap['firstname']);
    final last = jsonText(employeeMap['lastname']);
    return Interview(
      id: '${json['id']}',
      title: jsonText(json['title']) ?? 'Interview',
      status: InterviewStatus.fromKey(jsonText(json['status'])),
      scheduledAt:
          DateTime.tryParse(jsonText(json['scheduledAt']) ?? '') ?? DateTime(0),
      description: jsonText(json['description']),
      timezone: jsonText(json['timezone']),
      durationMinutes: jsonInt(json['durationMinutes']) ?? 60,
      location: jsonText(json['location']),
      meetingLink: jsonText(json['meetingLink']),
      applicationId: jsonText(json['applicationId']),
      employeeId: jsonText(employeeMap['id']),
      employeeName: [first, last].whereType<String>().join(' '),
    );
  }

  final String id;
  final String title;
  final InterviewStatus status;
  final DateTime scheduledAt;
  final String? description;
  final String? timezone;
  final int durationMinutes;
  final String? location;
  final String? meetingLink;
  final String? applicationId;
  final String? employeeId;
  final String? employeeName;
}

class EmployerAnalytics {
  const EmployerAnalytics({
    required this.openPositions,
    required this.activePipeline,
    required this.hired30d,
    required this.rejected30d,
    required this.applicationsCurrent,
    required this.applicationsDelta,
    required this.funnel,
    required this.topJobs,
    this.medianDaysToFirstMove,
  });

  factory EmployerAnalytics.fromJson(Map<String, dynamic> json) {
    final delta = json['applicationsDelta'];
    final deltaMap = delta is Map ? delta : const {};
    return EmployerAnalytics(
      openPositions: jsonInt(json['openPositions']) ?? 0,
      activePipeline: jsonInt(json['activePipeline']) ?? 0,
      hired30d: jsonInt(json['hired30d']) ?? 0,
      rejected30d: jsonInt(json['rejected30d']) ?? 0,
      applicationsCurrent: jsonInt(deltaMap['current']) ?? 0,
      applicationsDelta: jsonInt(deltaMap['delta']) ?? 0,
      medianDaysToFirstMove: json['medianDaysToFirstMove'] is num
          ? (json['medianDaysToFirstMove'] as num).toDouble()
          : null,
      funnel:
          jsonMaps(json['funnel']).map(EmployerFunnelStage.fromJson).toList(),
      topJobs: jsonMaps(json['topJobs']).map(EmployerTopJob.fromJson).toList(),
    );
  }

  final int openPositions;
  final int activePipeline;
  final int hired30d;
  final int rejected30d;
  final int applicationsCurrent;
  final int applicationsDelta;
  final double? medianDaysToFirstMove;
  final List<EmployerFunnelStage> funnel;
  final List<EmployerTopJob> topJobs;
}

class EmployerFunnelStage {
  const EmployerFunnelStage({required this.status, required this.count});
  factory EmployerFunnelStage.fromJson(Map<String, dynamic> json) =>
      EmployerFunnelStage(
        status: ApplicationStatus.fromKey(jsonText(json['status'])),
        count: jsonInt(json['count']) ?? 0,
      );
  final ApplicationStatus status;
  final int count;
}

class EmployerTopJob {
  const EmployerTopJob({
    required this.jobId,
    required this.title,
    required this.totalApplicants,
    required this.activePipeline,
    required this.hired,
    required this.rejected,
  });
  factory EmployerTopJob.fromJson(Map<String, dynamic> json) => EmployerTopJob(
        jobId: '${json['jobId']}',
        title: jsonText(json['title']) ?? 'Role',
        totalApplicants: jsonInt(json['totalApplicants']) ?? 0,
        activePipeline: jsonInt(json['activePipeline']) ?? 0,
        hired: jsonInt(json['hired']) ?? 0,
        rejected: jsonInt(json['rejected']) ?? 0,
      );
  final String jobId;
  final String title;
  final int totalApplicants;
  final int activePipeline;
  final int hired;
  final int rejected;
}

class BulkUpdateResult {
  const BulkUpdateResult({required this.updated, required this.failed});
  final int updated;
  final int failed;
}
