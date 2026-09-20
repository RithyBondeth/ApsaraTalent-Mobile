import 'package:apsaratalent_mobile/core/utils/json_parse.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';

/// Someone the viewer matched with, and how well they fit.
///
/// The API returns the counterpart profile *flattened* — the company's or
/// employee's own fields at the top level, with the two scores alongside — so
/// there is no match row to carry. `profile.id` is the counterpart's profile
/// id, which is what unmatching takes.
class MatchProfile {
  const MatchProfile({
    required this.profile,
    required this.matchScore,
    required this.skillScore,
  });

  factory MatchProfile.fromJson(
    Map<String, dynamic> json, {
    required bool viewerIsEmployee,
  }) =>
      MatchProfile(
        // An employee matched with companies; a company matched with talent.
        profile: viewerIsEmployee
            ? FeedCompany.fromJson(json)
            : FeedEmployee.fromJson(json),
        matchScore: jsonInt(json['matchScore']) ?? 0,
        skillScore: jsonInt(json['skillScore']) ?? 0,
      );

  final FeedProfile profile;

  /// The API's overall fit, 0–100.
  final int matchScore;

  /// How much of the fit comes from skills alone. Zero where neither side has
  /// filled enough in for it to mean anything, which is common.
  final int skillScore;
}

/// How many matches there are, and how many the viewer has not looked at.
class MatchCount {
  const MatchCount({required this.total, required this.unseen});

  factory MatchCount.fromJson(Map<String, dynamic> json) => MatchCount(
        total: jsonInt(json['count']) ?? 0,
        unseen: jsonInt(json['unseenCount']) ?? 0,
      );

  static const empty = MatchCount(total: 0, unseen: 0);

  final int total;
  final int unseen;
}
