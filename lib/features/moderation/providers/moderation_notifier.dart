import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/moderation/data/repositories/moderation_repository_impl.dart';
import 'package:apsaratalent_mobile/features/moderation/domain/entities/moderation.dart';
import 'package:apsaratalent_mobile/features/moderation/domain/repositories/moderation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>(
  (ref) => ModerationRepositoryImpl(ref.watch(apiClientProvider)),
);

class BlockedState {
  const BlockedState({this.users = const [], this.pendingIds = const {}});

  final List<BlockedUser> users;
  final Set<String> pendingIds;

  bool isPending(String userId) => pendingIds.contains(userId);

  BlockedState copyWith({List<BlockedUser>? users, Set<String>? pendingIds}) =>
      BlockedState(
        users: users ?? this.users,
        pendingIds: pendingIds ?? this.pendingIds,
      );
}

class BlockedNotifier extends AutoDisposeAsyncNotifier<BlockedState> {
  ModerationRepository get _repository => ref.read(moderationRepositoryProvider);

  @override
  Future<BlockedState> build() async =>
      BlockedState(users: await _repository.fetchBlocked());

  Future<void> refresh() async {
    state = AsyncData(BlockedState(users: await _repository.fetchBlocked()));
  }

  /// Blocks [userId]. Not optimistic: this list is the record of who is
  /// blocked, and showing someone on it before the API agreed would be
  /// claiming something about another account that might not be true.
  Future<void> block(String userId) async {
    await _repository.block(userId);
    _feedChanged();
    await refresh();
  }

  /// Unblocks. The row leaves at once and comes back if the request fails.
  Future<void> unblock(BlockedUser user) async {
    final current = state.value;
    if (current == null || current.isPending(user.userId)) return;

    state = AsyncData(current.copyWith(
      users: current.users.where((u) => u.userId != user.userId).toList(),
      pendingIds: {...current.pendingIds, user.userId},
    ));

    try {
      await _repository.unblock(user.userId);
      _feedChanged();
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(
          pendingIds: {...latest.pendingIds}..remove(user.userId),
        ));
      }
    } on ApiException {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(
          users: current.users,
          pendingIds: {...latest.pendingIds}..remove(user.userId),
        ));
      }
      rethrow;
    }
  }

  /// The feed hides blocked profiles from a set it loaded once, so a block or
  /// unblock has to make it reload — otherwise someone stays visible after
  /// being blocked, which is the whole point of blocking.
  void _feedChanged() => ref.invalidate(feedProvider);
}

final blockedProvider =
    AsyncNotifierProvider.autoDispose<BlockedNotifier, BlockedState>(
  BlockedNotifier.new,
);

/// Blocking and reporting from anywhere a profile is shown, without that
/// screen having to own the blocked list.
final moderationActionsProvider = Provider<ModerationActions>(
  (ref) => ModerationActions(ref),
);

class ModerationActions {
  const ModerationActions(this._ref);

  final Ref _ref;

  ModerationRepository get _repository =>
      _ref.read(moderationRepositoryProvider);

  Future<void> block(String userId) async {
    await _repository.block(userId);
    // Both lists are now wrong: the feed still shows them, and the blocked
    // list is missing them.
    _ref.invalidate(feedProvider);
    _ref.invalidate(blockedProvider);
  }

  /// Reporting deliberately does not block. Someone reporting a scam usually
  /// wants both, but reporting a bad job ad is not the same as refusing to
  /// see that company again, and the API keeps them separate.
  Future<void> report(
    String userId, {
    required ReportReason reason,
    String? details,
  }) =>
      _repository.report(userId, reason: reason, details: details);
}
