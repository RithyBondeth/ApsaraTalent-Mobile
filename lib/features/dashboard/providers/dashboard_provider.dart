import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/core/network/generated/gateway_api.dart';
import 'package:apsaratalent_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
    (ref) => DashboardRepository(ref.watch(apiClientProvider)));
final dashboardProvider =
    FutureProvider.autoDispose<ApiMatchingAnalyticsResponseDTO?>((ref) async {
  final viewer = ref.watch(feedViewerProvider);
  if (viewer == null) return null;
  return ref.watch(dashboardRepositoryProvider).fetch(viewer);
});
