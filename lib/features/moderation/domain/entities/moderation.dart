import 'package:apsaratalent_mobile/core/utils/json_parse.dart';

/// Why someone is being reported. These are the API's `EReportReason` values.
enum ReportReason {
  spam('Spam', 'Unsolicited or repetitive messages'),
  harassment('Harassment', 'Abusive, threatening or hateful behaviour'),
  inappropriateContent(
    'Inappropriate content',
    'Content that does not belong on a hiring platform',
  ),
  fakeProfile('Fake profile', 'Impersonation, or a profile that is not real'),
  scam('Scam', 'Fraud, or an attempt to take money'),
  other('Something else', 'Tell us what happened');

  const ReportReason(this.label, this.description);

  final String label;
  final String description;

  /// The API's key. `inappropriateContent` is `inappropriate_content` there,
  /// so this cannot just be [name].
  String get key => switch (this) {
        ReportReason.inappropriateContent => 'inappropriate_content',
        ReportReason.fakeProfile => 'fake_profile',
        _ => name,
      };
}

/// Someone the viewer has blocked.
class BlockedUser {
  const BlockedUser({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.role,
    this.blockedAt,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) => BlockedUser(
        // `id` here is the **user** id, which is what unblocking takes.
        userId: '${json['id']}',
        name: jsonText(json['name']) ?? 'Someone',
        avatarUrl: jsonText(json['avatar']),
        role: jsonText(json['role']),
        blockedAt: DateTime.tryParse(jsonText(json['blockedAt']) ?? ''),
      );

  final String userId;
  final String name;
  final String? avatarUrl;
  final String? role;
  final DateTime? blockedAt;

  String get roleLabel => switch (role) {
        'company' => 'Company',
        'employee' => 'Talent',
        _ => 'Account',
      };
}
