import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepositoryImpl(ref.watch(apiClientProvider)),
);

/// The profile the feed is for, or null for an admin or a phone login that has
/// no profile yet — neither has a feed.
final feedViewerProvider = Provider<FeedViewer?>((ref) {
  final user = ref.watch(authSessionProvider.select((s) => s.value?.user));
  final profileId = user?.profileId;
  if (user == null || profileId == null) return null;
  return switch (user.role) {
    EUserRole.employee =>
      FeedViewer(role: FeedViewerRole.employee, profileId: profileId),
    EUserRole.company =>
      FeedViewer(role: FeedViewerRole.company, profileId: profileId),
    _ => null,
  };
});

class FeedState {
  const FeedState({
    required this.viewer,
    this.profiles = const [],
    this.recommendations = const [],
    this.recommendationsError,
    this.likedIds = const {},
    this.favorites = const {},
    this.hiddenIds = const {},
    this.pendingIds = const {},
    this.unreadCount = 0,
    this.fetchedCount = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final FeedViewer viewer;

  /// Every page loaded so far, unfiltered.
  final List<FeedProfile> profiles;
  final List<FeedProfile> recommendations;

  /// Recommendations failing is not the feed failing; the section says so and
  /// the rest of the page still works.
  final String? recommendationsError;

  final Set<String> likedIds;

  /// Profile id → favourite id.
  final Map<String, String> favorites;
  final Set<String> hiddenIds;

  /// Profiles with a like or save in flight, so their buttons can't double-fire.
  final Set<String> pendingIds;

  final int unreadCount;

  /// Rows the API has returned, which is the next page's `skip`. It is not
  /// `profiles.length` once a page has come back short of a full one.
  final int fetchedCount;
  final bool hasMore;
  final bool isLoadingMore;
  final String? loadMoreError;

  bool _visible(FeedProfile p) =>
      !likedIds.contains(p.id) && !hiddenIds.contains(p.id);

  /// A liked profile leaves the feed at once, as it does on the web.
  List<FeedProfile> get visibleProfiles => profiles.where(_visible).toList();

  List<FeedProfile> get visibleRecommendations =>
      recommendations.where(_visible).toList();

  bool isSaved(String profileId) => favorites.containsKey(profileId);
  bool isPending(String profileId) => pendingIds.contains(profileId);

  FeedState copyWith({
    List<FeedProfile>? profiles,
    List<FeedProfile>? recommendations,
    Set<String>? likedIds,
    Map<String, String>? favorites,
    Set<String>? pendingIds,
    int? unreadCount,
    int? fetchedCount,
    bool? hasMore,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) =>
      FeedState(
        viewer: viewer,
        profiles: profiles ?? this.profiles,
        recommendations: recommendations ?? this.recommendations,
        recommendationsError: recommendationsError,
        likedIds: likedIds ?? this.likedIds,
        favorites: favorites ?? this.favorites,
        hiddenIds: hiddenIds,
        pendingIds: pendingIds ?? this.pendingIds,
        unreadCount: unreadCount ?? this.unreadCount,
        fetchedCount: fetchedCount ?? this.fetchedCount,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadMoreError:
            clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
      );
}

/// The outcome of a like, for the screen to announce.
enum FeedLikeOutcome { liked, matched }

class FeedNotifier extends AutoDisposeAsyncNotifier<FeedState?> {
  static const pageSize = 10;

  FeedRepository get _repository => ref.read(feedRepositoryProvider);

  @override
  Future<FeedState?> build() async {
    final viewer = ref.watch(feedViewerProvider);
    if (viewer == null) return null;
    return _load(viewer);
  }

  Future<FeedState> _load(FeedViewer viewer) async {
    final repository = _repository;

    // Everything starts at once. The page, likes and saves fail the load: the
    // feed would otherwise show already-liked cards and wrong save states.
    // The rest degrade — no recommendations, no badge, nothing hidden
    // client-side (the API already drops blocked profiles from the list).
    final recommendations = _attempt(repository.fetchRecommendations(viewer));
    final hidden = _orElse(repository.fetchHiddenIds(), <String>{});
    final unread = _orElse(repository.fetchUnreadNotificationCount(), 0);

    // Future.wait listens to all three before any settles, so a failure in
    // one while another is still pending is not reported as uncaught.
    final core = await Future.wait<Object>([
      repository.fetchProfiles(viewer, skip: 0, limit: pageSize),
      repository.fetchLikedIds(viewer),
      repository.fetchFavorites(viewer),
    ]);
    final profiles = core[0] as List<FeedProfile>;
    final (recs, recsError) = await recommendations;

    return FeedState(
      viewer: viewer,
      profiles: profiles,
      recommendations: recs,
      recommendationsError: recsError,
      likedIds: core[1] as Set<String>,
      favorites: core[2] as Map<String, String>,
      hiddenIds: await hidden,
      unreadCount: await unread,
      fetchedCount: profiles.length,
      hasMore: profiles.length == pageSize,
    );
  }

  Future<(List<FeedProfile>, String?)> _attempt(
    Future<List<FeedProfile>> future,
  ) async {
    try {
      return (await future, null);
    } on ApiException catch (e) {
      return (const <FeedProfile>[], e.message);
    }
  }

  Future<T> _orElse<T>(Future<T> future, T fallback) async {
    try {
      return await future;
    } on ApiException {
      return fallback;
    }
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

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreError: true),
    );
    try {
      final page = await _repository.fetchProfiles(
        current.viewer,
        skip: current.fetchedCount,
        limit: pageSize,
      );
      final known = current.profiles.map((p) => p.id).toSet();
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(
        // A profile can shift pages between requests; don't show it twice.
        profiles: [
          ...latest.profiles,
          ...page.where((p) => !known.contains(p.id)),
        ],
        fetchedCount: latest.fetchedCount + page.length,
        hasMore: page.length == pageSize,
        isLoadingMore: false,
      ));
    } on ApiException catch (e) {
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(isLoadingMore: false, loadMoreError: e.message),
      );
    }
  }

  /// Likes [profile]. The card leaves the feed immediately and comes back if
  /// the request fails. Throws [ApiException] on failure.
  Future<FeedLikeOutcome> like(FeedProfile profile) async {
    final current = state.value;
    if (current == null || current.isPending(profile.id)) {
      return FeedLikeOutcome.liked;
    }

    // The API drops a favourite when its profile is liked; mirror that now so
    // the saved count doesn't lag behind.
    final favorites = Map.of(current.favorites)..remove(profile.id);
    state = AsyncData(current.copyWith(
      likedIds: {...current.likedIds, profile.id},
      favorites: favorites,
      pendingIds: {...current.pendingIds, profile.id},
    ));

    try {
      final matched = await _repository.like(current.viewer, profile.id);
      _settle(profile.id);
      return matched ? FeedLikeOutcome.matched : FeedLikeOutcome.liked;
    } on ApiException {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(
          likedIds: {...latest.likedIds}..remove(profile.id),
          favorites: {
            ...latest.favorites,
            if (current.favorites[profile.id] != null)
              profile.id: current.favorites[profile.id]!,
          },
          pendingIds: {...latest.pendingIds}..remove(profile.id),
        ));
      }
      rethrow;
    }
  }

  /// Saves or unsaves [profile], optimistically. Returns whether it is now
  /// saved. Throws [ApiException] on failure, with the change rolled back.
  Future<bool> toggleSave(FeedProfile profile) async {
    final current = state.value;
    if (current == null || current.isPending(profile.id)) {
      return current?.isSaved(profile.id) ?? false;
    }
    var favoriteId = current.favorites[profile.id];
    // An empty id is a save whose favourite id never came back. Look it up
    // again rather than send an unsave the API cannot route.
    if (favoriteId != null && favoriteId.isEmpty) {
      favoriteId = (await _repository.fetchFavorites(current.viewer))[profile.id];
    }
    final saving = favoriteId == null;

    state = AsyncData(current.copyWith(
      // A placeholder until the real favourite id is fetched back.
      favorites: saving
          ? {...current.favorites, profile.id: ''}
          : (Map.of(current.favorites)..remove(profile.id)),
      pendingIds: {...current.pendingIds, profile.id},
    ));

    try {
      if (saving) {
        await _repository.favorite(current.viewer, profile.id);
        // The save response carries no id, and unsaving needs one. The save
        // itself has landed, so a failed lookup keeps the placeholder — the
        // next unsave looks the id up again — instead of rolling back.
        String? savedId;
        try {
          savedId = (await _repository.fetchFavorites(current.viewer))[profile.id];
        } on ApiException {
          savedId = null;
        }
        final latest = state.value;
        if (latest != null && savedId != null) {
          state = AsyncData(latest.copyWith(
            favorites: {...latest.favorites, profile.id: savedId},
          ));
        }
      } else {
        await _repository.unfavorite(current.viewer, profile.id, favoriteId);
      }
      _settle(profile.id);
      return saving;
    } on ApiException {
      final latest = state.value;
      if (latest != null) {
        final favorites = Map.of(latest.favorites);
        saving
            ? favorites.remove(profile.id)
            : favorites[profile.id] = favoriteId;
        state = AsyncData(latest.copyWith(
          favorites: favorites,
          pendingIds: {...latest.pendingIds}..remove(profile.id),
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

final feedProvider =
    AsyncNotifierProvider.autoDispose<FeedNotifier, FeedState?>(
  FeedNotifier.new,
);
