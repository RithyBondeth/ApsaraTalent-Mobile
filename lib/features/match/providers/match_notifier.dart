import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/match/data/repositories/match_repository_impl.dart';
import 'package:apsaratalent_mobile/features/match/domain/entities/match_profile.dart';
import 'package:apsaratalent_mobile/features/match/domain/repositories/match_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matchRepositoryProvider = Provider<MatchRepository>(
  (ref) => MatchRepositoryImpl(ref.watch(apiClientProvider)),
);

/// The badge on the feed header. Separate from [matchesProvider] so showing
/// the count costs one small request rather than loading every match.
///
/// A count failure is not worth a visible error — the badge simply does not
/// appear, and the matches screen reports the real problem when opened.
final matchCountProvider = FutureProvider.autoDispose<MatchCount>((ref) async {
  final viewer = ref.watch(feedViewerProvider);
  if (viewer == null) return MatchCount.empty;
  try {
    return await ref.read(matchRepositoryProvider).fetchCount(viewer);
  } on ApiException {
    return MatchCount.empty;
  }
});

class MatchesState {
  const MatchesState({
    required this.viewer,
    this.matches = const [],
    this.pendingIds = const {},
  });

  final FeedViewer viewer;
  final List<MatchProfile> matches;

  /// Matches with an unmatch in flight, so the button cannot double-fire.
  final Set<String> pendingIds;

  bool isPending(String profileId) => pendingIds.contains(profileId);

  MatchesState copyWith({
    List<MatchProfile>? matches,
    Set<String>? pendingIds,
  }) =>
      MatchesState(
        viewer: viewer,
        matches: matches ?? this.matches,
        pendingIds: pendingIds ?? this.pendingIds,
      );
}

class MatchesNotifier extends AutoDisposeAsyncNotifier<MatchesState?> {
  MatchRepository get _repository => ref.read(matchRepositoryProvider);

  @override
  Future<MatchesState?> build() async {
    final viewer = ref.watch(feedViewerProvider);
    if (viewer == null) return null;
    return MatchesState(
      viewer: viewer,
      matches: await _repository.fetchMatches(viewer),
    );
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) {
      ref.invalidateSelf();
      await future;
      return;
    }
    state = AsyncData(current.copyWith(
      matches: await _repository.fetchMatches(current.viewer),
    ));
  }

  /// Marks every match seen. Called once when the screen opens, because
  /// looking at the list is what "seen" means — there is no per-match route.
  ///
  /// Failure is swallowed: the badge staying up is a small, self-correcting
  /// problem, and an error about it would interrupt reading the matches that
  /// did load.
  Future<void> markSeen() async {
    final current = state.value;
    if (current == null || current.matches.isEmpty) return;
    try {
      await _repository.markSeen(current.viewer);
      ref.invalidate(matchCountProvider);
    } on ApiException {
      // Deliberately ignored; see above.
    }
  }

  /// Ends the match with [match]. The card leaves the list at once and comes
  /// back if the request fails. Throws [ApiException].
  Future<void> unmatch(MatchProfile match) async {
    final current = state.value;
    final id = match.profile.id;
    if (current == null || current.isPending(id)) return;

    state = AsyncData(current.copyWith(
      matches: current.matches.where((m) => m.profile.id != id).toList(),
      pendingIds: {...current.pendingIds, id},
    ));

    try {
      await _repository.unmatch(current.viewer, id);
      ref.invalidate(matchCountProvider);
      // Unmatching deletes the whole job_matching row, which is where both
      // sides' likes live — so it un-likes in both directions, and the
      // counterpart becomes a feed card again. The feed hides liked profiles
      // from a set it loaded once, so without this it would keep hiding
      // someone the API no longer considers liked.
      ref.invalidate(feedProvider);
      _settle(id);
    } on ApiException {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(
          // Back in the API's order, not appended.
          matches: current.matches,
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

final matchesProvider =
    AsyncNotifierProvider.autoDispose<MatchesNotifier, MatchesState?>(
  MatchesNotifier.new,
);
