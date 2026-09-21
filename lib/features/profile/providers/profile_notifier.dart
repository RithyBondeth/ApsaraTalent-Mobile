import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(apiClientProvider)),
);

/// The signed-in user's profile, or null for an account that has none — an
/// admin, or a phone login that has not finished onboarding.
class ProfileNotifier extends AutoDisposeAsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    // The same viewer the feed and the favourites screen use: role plus the
    // profile id, off the current user.
    final viewer = ref.watch(feedViewerProvider);
    if (viewer == null) return null;
    return ref.read(profileRepositoryProvider).fetchProfile(viewer);
  }

  /// Saves [changes] and replaces the profile with what came back.
  ///
  /// Only changed keys are sent. The API `Object.assign`s whatever it
  /// receives, so restating an unchanged field is harmless but sending a key
  /// nobody edited is a write nobody asked for — and for `job` it would
  /// re-trigger the server's embedding work for no reason.
  ///
  /// Does nothing when [changes] is empty. Throws [ApiException].
  Future<void> save(Map<String, dynamic> changes) async {
    if (changes.isEmpty) return;
    final viewer = ref.read(feedViewerProvider);
    if (viewer == null) return;
    final saved =
        await ref.read(profileRepositoryProvider).updateProfile(viewer, changes);
    state = AsyncData(saved);
  }

  /// Pull-to-refresh. The current profile stays up while it runs, and stays up
  /// if it fails — the ApiException is rethrown for the screen to report.
  Future<void> refresh() async {
    final current = state.value;
    if (current == null) {
      ref.invalidateSelf();
      await future;
      return;
    }
    final viewer = ref.read(feedViewerProvider);
    if (viewer == null) return;
    state = AsyncData(
      await ref.read(profileRepositoryProvider).fetchProfile(viewer),
    );
  }
}

final profileProvider =
    AsyncNotifierProvider.autoDispose<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);
