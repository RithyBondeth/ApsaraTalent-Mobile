import 'dart:typed_data';

enum ProblemCategory {
  bug('bug', 'App bug'),
  account('account', 'Account'),
  payment('payment', 'Payment'),
  content('content', 'Content'),
  other('other', 'Other');

  const ProblemCategory(this.key, this.label);
  final String key;
  final String label;
}

class RecentProfileViewer {
  const RecentProfileViewer({
    required this.name,
    required this.viewedAt,
    this.avatarUrl,
    this.role,
  });

  factory RecentProfileViewer.fromJson(Map<String, dynamic> json) =>
      RecentProfileViewer(
        name: json['viewerName'] is String &&
                (json['viewerName'] as String).trim().isNotEmpty
            ? (json['viewerName'] as String).trim()
            : 'Private viewer',
        avatarUrl: json['viewerAvatar'] as String?,
        role: json['viewerRole'] as String?,
        viewedAt: DateTime.tryParse('${json['viewedAt'] ?? ''}'),
      );

  final String name;
  final String? avatarUrl;
  final String? role;
  final DateTime? viewedAt;
}

class ProfileAnalytics {
  const ProfileAnalytics({
    required this.profileViews7d,
    required this.profileViews30d,
    required this.searchAppearances30d,
    required this.browsePrivately,
    required this.recentViewers,
  });

  factory ProfileAnalytics.fromJson(Map<String, dynamic> json) {
    final viewers = json['recentViewers'];
    return ProfileAnalytics(
      profileViews7d: (json['profileViews7d'] as num?)?.toInt() ?? 0,
      profileViews30d: (json['profileViews30d'] as num?)?.toInt() ?? 0,
      searchAppearances30d:
          (json['searchAppearances30d'] as num?)?.toInt() ?? 0,
      browsePrivately: json['browsePrivately'] == true,
      recentViewers: viewers is List
          ? viewers
              .whereType<Map>()
              .map((v) =>
                  RecentProfileViewer.fromJson(v.cast<String, dynamic>()))
              .toList()
          : const [],
    );
  }

  final int profileViews7d;
  final int profileViews30d;
  final int searchAppearances30d;
  final bool browsePrivately;
  final List<RecentProfileViewer> recentViewers;

  ProfileAnalytics withPrivacy(bool value) => ProfileAnalytics(
        profileViews7d: profileViews7d,
        profileViews30d: profileViews30d,
        searchAppearances30d: searchAppearances30d,
        browsePrivately: value,
        recentViewers: recentViewers,
      );
}

class AccountExport {
  const AccountExport({required this.fileName, required this.bytes});
  final String fileName;
  final Uint8List bytes;
}

class AccountDeletionResult {
  const AccountDeletionResult(
      {required this.message, required this.scheduledFor});
  final String message;
  final DateTime scheduledFor;
}
