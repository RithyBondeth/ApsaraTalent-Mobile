import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';

/// Which side of the marketplace is looking. An employee's feed is companies;
/// a company's feed is employees.
enum FeedViewerRole { employee, company }

/// The signed-in profile the feed is built for.
class FeedViewer {
  const FeedViewer({required this.role, required this.profileId});

  final FeedViewerRole role;

  /// The employee's or company's id, not the user id.
  final String profileId;

  @override
  bool operator ==(Object other) =>
      other is FeedViewer &&
      other.role == role &&
      other.profileId == profileId;

  @override
  int get hashCode => Object.hash(role, profileId);
}

/// All feed traffic for one viewer. Every method speaks in the viewer's terms,
/// so callers never pick between the employee and company flavour of a route.
abstract class FeedRepository {
  /// One page of the counterpart profiles, in the API's order.
  Future<List<FeedProfile>> fetchProfiles(
    FeedViewer viewer, {
    required int skip,
    required int limit,
  });

  Future<List<FeedProfile>> fetchRecommendations(FeedViewer viewer);

  /// Ids of profiles the viewer has already liked.
  Future<Set<String>> fetchLikedIds(FeedViewer viewer);

  /// The viewer's saved profiles, in the order the API returns them.
  ///
  /// The list response carries each saved profile in full, so the favourites
  /// screen needs no second request to render its cards.
  Future<List<FavoriteProfile>> fetchFavoriteProfiles(FeedViewer viewer);

  /// Profile id → favourite id. Unfavouriting needs the favourite's own id.
  /// A projection of [fetchFavoriteProfiles], for callers that only need to
  /// know what is saved — the feed, which shows a bookmark on every card.
  Future<Map<String, String>> fetchFavorites(FeedViewer viewer);

  /// Profile ids hidden by a block in either direction.
  Future<Set<String>> fetchHiddenIds();

  Future<int> fetchUnreadNotificationCount();

  /// Returns whether the like completed a match.
  Future<bool> like(FeedViewer viewer, String profileId);

  Future<void> favorite(FeedViewer viewer, String profileId);

  Future<void> unfavorite(
    FeedViewer viewer,
    String profileId,
    String favoriteId,
  );
}
