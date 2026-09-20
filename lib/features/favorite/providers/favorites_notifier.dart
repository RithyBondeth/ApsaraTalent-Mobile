import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesState {
  const FavoritesState({
    required this.viewer,
    this.favorites = const [],
    this.likedIds = const {},
    this.pendingIds = const {},
  });

  final FeedViewer viewer;

  /// Everything the API returned, unfiltered.
  final List<FavoriteProfile> favorites;

  final Set<String> likedIds;

  /// Profiles with a removal in flight, so their buttons can't double-fire.
  final Set<String> pendingIds;

  /// Liking a profile drops its favourite server-side, so a liked profile
  /// still in this list is stale — a like from another device, or from the
  /// feed in this session. The web filters the same way, for the same reason.
  List<FavoriteProfile> get visible =>
      favorites.where((f) => !likedIds.contains(f.profile.id)).toList();

  bool isPending(String profileId) => pendingIds.contains(profileId);

  FavoritesState copyWith({
    List<FavoriteProfile>? favorites,
    Set<String>? likedIds,
    Set<String>? pendingIds,
  }) =>
      FavoritesState(
        viewer: viewer,
        favorites: favorites ?? this.favorites,
        likedIds: likedIds ?? this.likedIds,
        pendingIds: pendingIds ?? this.pendingIds,
      );
}

class FavoritesNotifier extends AutoDisposeAsyncNotifier<FavoritesState?> {
  FeedRepository get _repository => ref.read(feedRepositoryProvider);

  @override
  Future<FavoritesState?> build() async {
    final viewer = ref.watch(feedViewerProvider);
    if (viewer == null) return null;
    return _load(viewer);
  }

  Future<FavoritesState> _load(FeedViewer viewer) async {
    final repository = _repository;

    // Both fail the screen. Showing saved profiles without knowing which are
    // liked would leave stale cards that vanish on the next open, which reads
    // as the app losing saves.
    final results = await Future.wait<Object>([
      repository.fetchFavoriteProfiles(viewer),
      repository.fetchLikedIds(viewer),
    ]);

    return FavoritesState(
      viewer: viewer,
      favorites: results[0] as List<FavoriteProfile>,
      likedIds: results[1] as Set<String>,
    );
  }

  /// Pull-to-refresh. The current cards stay up while it runs, and stay up if
  /// it fails — the [ApiException] is rethrown for the screen to report.
  Future<void> refresh() async {
    final current = state.value;
    if (current == null) {
      ref.invalidateSelf();
      await future;
      return;
    }
    state = AsyncData(await _load(current.viewer));
  }

  /// Unsaves [favorite]. The card leaves the list immediately and comes back
  /// if the request fails. Throws [ApiException] on failure.
  Future<void> remove(FavoriteProfile favorite) async {
    final current = state.value;
    final id = favorite.profile.id;
    if (current == null || current.isPending(id)) return;

    state = AsyncData(current.copyWith(
      favorites: current.favorites.where((f) => f.profile.id != id).toList(),
      pendingIds: {...current.pendingIds, id},
    ));

    try {
      await _repository.unfavorite(current.viewer, id, favorite.favoriteId);
      // The feed shows a bookmark on every card; its copy of this save is now
      // wrong. Invalidating reloads it the next time the tab is looked at.
      ref.invalidate(feedProvider);
      _settle(id);
    } on ApiException {
      final latest = state.value;
      if (latest != null) {
        // Back where it was, not appended — the list is in the API's order.
        final restored = [...current.favorites];
        state = AsyncData(latest.copyWith(
          favorites: restored,
          pendingIds: {...latest.pendingIds}..remove(id),
        ));
      }
      rethrow;
    }
  }

  void _settle(String profileId) {
    final latest = state.value;
    if (latest == null) return;
    state = AsyncData(latest.copyWith(
      pendingIds: {...latest.pendingIds}..remove(profileId),
    ));
  }
}

final favoritesProvider =
    AsyncNotifierProvider.autoDispose<FavoritesNotifier, FavoritesState?>(
  FavoritesNotifier.new,
);
