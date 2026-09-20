import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/setting/data/repositories/activity_counts_repository.dart';
import 'package:apsaratalent_mobile/features/setting/domain/entities/activity_counts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activityCountsRepositoryProvider = Provider<ActivityCountsRepository>(
  (ref) => ActivityCountsRepository(ref.watch(apiClientProvider)),
);

/// The Activity counts on the settings page.
///
/// Never fails: the repository resolves each count to null on error, and an
/// account with no profile has none of them. A settings page that could not
/// open because a count was unavailable would be a poor trade.
final activityCountsProvider =
    FutureProvider.autoDispose<ActivityCounts>((ref) async {
  final viewer = ref.watch(feedViewerProvider);
  if (viewer == null) return const ActivityCounts();
  return ref.read(activityCountsRepositoryProvider).fetch(viewer);
});
