import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/match/domain/entities/match_profile.dart';

/// [FeedViewer] is reused: matches are the same two-sided split the feed
/// makes, and every route here is addressed by profile id.
abstract class MatchRepository {
  Future<List<MatchProfile>> fetchMatches(FeedViewer viewer);

  Future<MatchCount> fetchCount(FeedViewer viewer);

  /// Marks every match seen at once — the API has no per-match variant — and
  /// answers with the count it leaves behind.
  Future<MatchCount> markSeen(FeedViewer viewer);

  /// Ends the match for both sides. Irreversible short of both liking again.
  Future<void> unmatch(FeedViewer viewer, String profileId);
}
