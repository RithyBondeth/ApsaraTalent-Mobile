import 'package:apsaratalent_mobile/core/constants/apis/feed_api_constant.dart';
import 'package:apsaratalent_mobile/core/constants/apis/activity_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/setting/domain/entities/activity_counts.dart';

/// Reads the three Activity counts. Nothing here fails the settings page:
/// every count resolves to null on error, and its row simply has no number.
class ActivityCountsRepository {
  ActivityCountsRepository(this._client);

  final ApiClient _client;

  Future<ActivityCounts> fetch(FeedViewer viewer) async {
    final results = await Future.wait([
      _applications(),
      _saved(viewer),
      _unread(),
    ]);
    return ActivityCounts(
      applications: results[0],
      saved: results[1],
      unread: results[2],
    );
  }

  /// No count route exists, so the list is fetched and counted.
  Future<int?> _applications() => _orNull(() async {
        final response = await _client.get(apiMyApplications);
        final data = response.data;
        return data is List ? data.length : null;
      });

  Future<int?> _saved(FeedViewer viewer) => _orNull(() async {
        final response = await _client.get(
          viewer.role == FeedViewerRole.employee
              ? apiEmployeeFavoriteCount(viewer.profileId)
              : apiCompanyFavoriteCount(viewer.profileId),
        );
        return _number(response.data, 'count');
      });

  Future<int?> _unread() => _orNull(() async {
        final response = await _client.get(apiNotificationUnreadCount);
        return _number(response.data, 'unreadCount');
      });

  int? _number(dynamic data, String key) {
    if (data is! Map) return null;
    final value = data[key];
    return value is int ? value : null;
  }

  Future<int?> _orNull(Future<int?> Function() body) async {
    try {
      return await body();
    } on ApiException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
