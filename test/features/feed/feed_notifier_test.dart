import 'dart:async';

import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

FeedCompany company(String id) => FeedCompany(id: id, name: 'Company $id');

class FakeFeedRepository implements FeedRepository {
  /// Every company the API would page through.
  List<FeedProfile> all = List.generate(25, (i) => company('c$i'));
  List<FeedProfile> recommendations = [company('c0'), company('c1')];
  Set<String> liked = {};
  Map<String, String> favorites = {};
  Set<String> hidden = {};
  bool failRecommendations = false;
  bool failLike = false;
  bool failPage = false;
  bool matchOnLike = false;
  Completer<void>? likeGate;
  final List<int> pagesRequested = [];

  @override
  Future<List<FeedProfile>> fetchProfiles(
    FeedViewer viewer, {
    required int skip,
    required int limit,
  }) async {
    pagesRequested.add(skip);
    if (failPage) throw ApiException(message: 'page failed');
    return all.skip(skip).take(limit).toList();
  }

  @override
  Future<List<FeedProfile>> fetchRecommendations(FeedViewer viewer) async {
    if (failRecommendations) throw ApiException(message: 'recs down');
    return recommendations;
  }

  @override
  Future<Set<String>> fetchLikedIds(FeedViewer viewer) async => {...liked};

  @override
  Future<List<FavoriteProfile>> fetchFavoriteProfiles(FeedViewer viewer) async {
    final byId = {for (final p in all) p.id: p};
    return [
      for (final entry in favorites.entries)
        if (byId[entry.key] case final profile?)
          FavoriteProfile(profile: profile, favoriteId: entry.value),
    ];
  }

  @override
  Future<Map<String, String>> fetchFavorites(FeedViewer viewer) async =>
      {...favorites};

  @override
  Future<Set<String>> fetchHiddenIds() async => hidden;

  @override
  Future<int> fetchUnreadNotificationCount() async => 3;

  @override
  Future<bool> like(FeedViewer viewer, String profileId) async {
    await likeGate?.future;
    if (failLike) throw ApiException(message: 'like failed');
    liked.add(profileId);
    favorites.remove(profileId);
    return matchOnLike;
  }

  @override
  Future<void> favorite(FeedViewer viewer, String profileId) async {
    favorites[profileId] = 'fav-$profileId';
  }

  @override
  Future<void> unfavorite(
    FeedViewer viewer,
    String profileId,
    String favoriteId,
  ) async {
    expect(favoriteId, isNotEmpty);
    favorites.remove(profileId);
  }
}

void main() {
  late FakeFeedRepository repository;
  ProviderContainer? container;

  setUp(() => repository = FakeFeedRepository());
  tearDown(() {
    container?.dispose();
    container = null;
  });

  /// Builds the container on first use, so each test configures the fake
  /// before the feed's first load reads it.
  ProviderContainer feed() {
    return container ??= () {
      final created = ProviderContainer(overrides: [
        feedRepositoryProvider.overrideWithValue(repository),
        feedViewerProvider.overrideWithValue(
          const FeedViewer(role: FeedViewerRole.employee, profileId: 'e1'),
        ),
      ]);
      // Keep the auto-dispose provider alive for the length of a test.
      created.listen(feedProvider, (_, __) {});
      return created;
    }();
  }

  Future<FeedState> load() async {
    final FeedState? state = await feed().read(feedProvider.future);
    return state!;
  }

  FeedState current() => feed().read(feedProvider).value!;
  FeedNotifier notifier() => feed().read(feedProvider.notifier);

  test('loads the first page, recommendations, likes and the badge', () async {
    repository.liked = {'c2'};
    repository.hidden = {'c3'};

    final state = await load();

    expect(repository.pagesRequested, [0]);
    expect(state.profiles, hasLength(FeedNotifier.pageSize));
    expect(state.hasMore, isTrue);
    expect(state.unreadCount, 3);
    // Liked and blocked profiles never show.
    expect(state.visibleProfiles.map((p) => p.id), isNot(contains('c2')));
    expect(state.visibleProfiles.map((p) => p.id), isNot(contains('c3')));
  });

  test('a recommendations outage leaves the rest of the feed working', () async {
    repository.failRecommendations = true;

    final state = await load();

    expect(state.recommendations, isEmpty);
    expect(state.recommendationsError, 'recs down');
    expect(state.profiles, isNotEmpty);
  });

  test('a failed first page fails the feed', () async {
    repository.failPage = true;

    await expectLater(feed().read(feedProvider.future), throwsA(isA<ApiException>()));
  });

  test('pages on from what the API returned and stops at a short page', () async {
    await load();

    await notifier().loadMore();
    expect(repository.pagesRequested, [0, 10]);
    expect(current().profiles, hasLength(20));
    expect(current().hasMore, isTrue);

    await notifier().loadMore();
    expect(repository.pagesRequested, [0, 10, 20]);
    expect(current().profiles, hasLength(25));
    expect(current().hasMore, isFalse);

    // Nothing left to ask for.
    await notifier().loadMore();
    expect(repository.pagesRequested, [0, 10, 20]);
  });

  test('a failed page keeps the cards and records the error', () async {
    await load();
    repository.failPage = true;

    await notifier().loadMore();

    expect(current().profiles, hasLength(10));
    expect(current().loadMoreError, 'page failed');
    expect(current().isLoadingMore, isFalse);
  });

  test('a like hides the card at once and blocks a second tap', () async {
    await load();
    repository.likeGate = Completer<void>();
    final target = current().profiles.first;

    final pending = notifier().like(target);
    expect(current().visibleProfiles.map((p) => p.id), isNot(contains(target.id)));
    expect(current().isPending(target.id), isTrue);

    // A second like while the first is in flight is ignored.
    await notifier().like(target);

    repository.likeGate!.complete();
    expect(await pending, FeedLikeOutcome.liked);
    expect(current().isPending(target.id), isFalse);
  });

  test('a like reports a match', () async {
    await load();
    repository.matchOnLike = true;

    expect(
      await notifier().like(current().profiles.first),
      FeedLikeOutcome.matched,
    );
  });

  test('a failed like puts the card and its saved state back', () async {
    repository.favorites = {'c0': 'fav-c0'};
    await load();
    repository.failLike = true;
    final target = current().profiles.first;

    await expectLater(notifier().like(target), throwsA(isA<ApiException>()));

    expect(current().visibleProfiles.first.id, target.id);
    expect(current().favorites, {'c0': 'fav-c0'});
    expect(current().isPending(target.id), isFalse);
  });

  test('saving fetches back the favourite id that unsaving needs', () async {
    await load();
    final target = current().profiles[4];

    expect(await notifier().toggleSave(target), isTrue);
    expect(current().favorites[target.id], 'fav-${target.id}');

    expect(await notifier().toggleSave(target), isFalse);
    expect(current().isSaved(target.id), isFalse);
  });
}
