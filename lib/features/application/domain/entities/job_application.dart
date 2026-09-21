import 'package:apsaratalent_mobile/core/utils/json_parse.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// Where an application stands.
///
/// These are the API's `EApplicationStatus` values. A company moves an
/// application through them; [withdrawn] is the employee's own and the only
/// one this screen can cause.
enum ApplicationStatus {
  pending('Pending', 'Waiting for the company to look', AppStatus.info),

  /// Legacy: Postgres cannot drop an enum label, and rows may still carry it.
  /// Unreachable through any transition — `reviewedAt` answers this now.
  reviewed('Reviewed', 'Seen by the company', AppStatus.info),

  shortlisted('Shortlisted', 'You made the shortlist', AppStatus.success),
  interviewing('Interviewing', 'Interviews under way', AppStatus.success),
  offered('Offered', 'An offer is on the table', AppStatus.success),
  hired('Hired', 'You got it', AppStatus.success),
  rejected('Not selected', 'The company passed', AppStatus.destructive),
  withdrawn('Withdrawn', 'You pulled out', AppStatus.warning),

  /// A value this build has not heard of. Shown rather than hidden.
  unknown('Unknown', '', AppStatus.info);

  const ApplicationStatus(this.label, this.description, this.tone);

  final String label;
  final String description;
  final AppStatus tone;

  /// Still in play: neither rejected, withdrawn, nor finished.
  bool get isOpen => switch (this) {
        ApplicationStatus.rejected ||
        ApplicationStatus.withdrawn ||
        ApplicationStatus.hired =>
          false,
        _ => true,
      };

  /// Only an application still in play can be withdrawn.
  bool get canWithdraw => isOpen;

  static ApplicationStatus fromKey(String? key) {
    for (final status in ApplicationStatus.values) {
      if (status.name == key) return status;
    }
    return ApplicationStatus.unknown;
  }
}

class JobApplication {
  const JobApplication({
    required this.id,
    required this.status,
    this.jobId,
    this.jobTitle,
    this.coverLetterNote,
    this.rejectionReason,
    this.appliedAt,
    this.reviewedAt,
    this.statusChangedAt,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) => JobApplication(
        id: '${json['id']}',
        status: ApplicationStatus.fromKey(jsonText(json['status'])),
        jobId: jsonText(json['jobId']),
        jobTitle: jsonText(json['jobTitle']),
        coverLetterNote: jsonText(json['coverLetterNote']),
        rejectionReason: jsonText(json['rejectionReason']),
        appliedAt: DateTime.tryParse(jsonText(json['appliedAt']) ?? ''),
        reviewedAt: DateTime.tryParse(jsonText(json['reviewedAt']) ?? ''),
        statusChangedAt:
            DateTime.tryParse(jsonText(json['statusChangedAt']) ?? ''),
      );

  final String id;
  final ApplicationStatus status;
  final String? jobId;

  /// The role applied for. The company is **not** in this payload — see the
  /// note on the screen.
  final String? jobTitle;
  final String? coverLetterNote;

  /// Set only on a rejection, and only when the company gave one.
  final String? rejectionReason;

  final DateTime? appliedAt;

  /// Null until the owning company first opens its applicant list.
  final DateTime? reviewedAt;

  /// Null while the application has never left pending.
  final DateTime? statusChangedAt;

  JobApplication copyWith({ApplicationStatus? status}) => JobApplication(
        id: id,
        status: status ?? this.status,
        jobId: jobId,
        jobTitle: jobTitle,
        coverLetterNote: coverLetterNote,
        rejectionReason: rejectionReason,
        appliedAt: appliedAt,
        reviewedAt: reviewedAt,
        statusChangedAt: statusChangedAt,
      );

  /// "Applied 3d ago", or nothing when the date is missing.
  String get appliedAge {
    final appliedAt = this.appliedAt;
    if (appliedAt == null) return '';
    final elapsed = DateTime.now().difference(appliedAt);
    if (elapsed.inMinutes < 60) return 'Applied just now';
    if (elapsed.inHours < 24) return 'Applied ${elapsed.inHours}h ago';
    if (elapsed.inDays < 7) return 'Applied ${elapsed.inDays}d ago';
    return 'Applied ${(elapsed.inDays / 7).floor()}w ago';
  }
}
