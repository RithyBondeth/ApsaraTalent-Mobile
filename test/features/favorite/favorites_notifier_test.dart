import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/favorite/providers/favorites_notifier.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

FeedCompany company(String id) => FeedCompany(id: id, name: 'Company $id');

class FakeFavoritesRepository implements FeedRepository {
  /// Profile id → favourite id, in the order the API would return them.
  Map<String, String> favorites = {'c1': 'fav1', 'c2': 'fav2', 'c3': 'fav3'};
  Set<String> liked = {};
  bool failLoad = false;
  bool failUnfavorite = false;
  final List<String> unfavorited = [];

  @override
  Future<List<FavoriteProfile>> fetchFavoriteProfiles(FeedViewer viewer) async {
    if (failLoad) throw ApiException(message: 'favourites down');
    return [
      for (final entry in favorites.entries)
        FavoriteProfile(profile: company(entry.key), favoriteId: entry.value),
    ];
  }

  @override
  Future<Map<String, String>> fetchFavorites(FeedViewer viewer) async =>
      {...favorites};

  @override
  Future<Set<String>> fetchLikedIds(FeedViewer viewer) async => {...liked};

  @override
  Future<void> unfavorite(
    FeedViewer viewer,
    String profileId,
    String favoriteId,
  ) async {
    if (failUnfavorite) throw ApiException(message: 'remove failed');
    unfavorited.add('$profileId/$favoriteId');
    favorites.remove(profileId);
  }

  // Not reached from the favourites screen.
  @override
  Future<List<FeedProfile>> fetchProfiles(
    FeedViewer viewer, {
    required int skip,
    required int limit,
  }) async =>
      const [];
  @override
  Future<List<FeedProfile>> fetchRecommendations(FeedViewer viewer) async =>
      const [];
  @override
  Future<Set<String>> fetchHiddenIds() async => {};
  @override
  Future<int> fetchUnreadNotificationCount() async => 0;
  @override
  Future<bool> like(FeedViewer viewer, String profileId) async => false;
  @override
  Future<void> favorite(FeedViewer viewer, String profileId) async {}
}

void main() {
  const viewer = FeedViewer(role: FeedViewerRole.employee, profileId: 'e1');

  late FakeFavoritesRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeFavoritesRepository();
    container = ProviderContainer(overrides: [
      feedRepositoryProvider.overrideWithValue(repository),
      feedViewerProvider.overrideWithValue(viewer),
    ]);
    addTearDown(container.dispose);
  });

  Future<FavoritesState> load() async {
    final state = await container.read(favoritesProvider.future);
    return state!;
  }

  test('loads the saved profiles with their favourite ids', () async {
    final state = await load();

    expect(state.visible.map((f) => f.profile.id), ['c1', 'c2', 'c3']);
    expect(state.visible.first.favoriteId, 'fav1');
  });

  test('a liked profile is filtered out of the saved list', () async {
    // The API drops a favourite when its profile is liked, so a liked profile
    // still in the list is stale — a like from the feed, or another device.
    repository.liked = {'c2'};

    final state = await load();

    expect(state.favorites, hasLength(3));
    expect(state.visible.map((f) => f.profile.id), ['c1', 'c3']);
  });

  test('a failed load fails the screen', () async {
    repository.failLoad = true;

    await expectLater(
      container.read(favoritesProvider.future),
      throwsA(isA<ApiException>()),
    );
  });

  test('removing takes the card out at once and sends the favourite id',
      () async {
    final state = await load();
    final target = state.visible[1];

    await container.read(favoritesProvider.notifier).remove(target);

    expect(repository.unfavorited, ['c2/fav2']);
    final latest = container.read(favoritesProvider).value!;
    expect(latest.visible.map((f) => f.profile.id), ['c1', 'c3']);
    expect(latest.isPending('c2'), isFalse);
  });

  test('a failed removal puts the card back where it was', () async {
    final state = await load();
    final target = state.visible[1];
    repository.failUnfavorite = true;

    await expectLater(
      container.read(favoritesProvider.notifier).remove(target),
      throwsA(isA<ApiException>()),
    );

    final latest = container.read(favoritesProvider).value!;
    // Back in position, not appended — the list is in the API's order.
    expect(latest.visible.map((f) => f.profile.id), ['c1', 'c2', 'c3']);
    expect(latest.isPending('c2'), isFalse);
  });

  test('a second remove while the first is in flight is ignored', () async {
    final state = await load();
    final target = state.visible.first;
    final notifier = container.read(favoritesProvider.notifier);

    await Future.wait([notifier.remove(target), notifier.remove(target)]);

    expect(repository.unfavorited, ['c1/fav1']);
  });
}
