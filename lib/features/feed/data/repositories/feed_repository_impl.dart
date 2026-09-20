import 'package:apsaratalent_mobile/core/constants/apis/feed_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._client);

  final ApiClient _client;

  bool _isEmployee(FeedViewer viewer) => viewer.role == FeedViewerRole.employee;

  /// An employee sees companies; a company sees employees.
  FeedProfile _parse(FeedViewer viewer, Map<String, dynamic> json) =>
      _isEmployee(viewer) ? FeedCompany.fromJson(json) : FeedEmployee.fromJson(json);

  @override
  Future<List<FeedProfile>> fetchProfiles(
    FeedViewer viewer, {
    required int skip,
    required int limit,
  }) =>
      _guard('Could not load the feed.', () async {
        final response = await _client.get(
          _isEmployee(viewer) ? apiCompaniesAll : apiEmployeesAll,
          queryParameters: {'skip': skip, 'limit': limit},
        );
        return _list(response.data).map((j) => _parse(viewer, j)).toList();
      });

  @override
  Future<List<FeedProfile>> fetchRecommendations(FeedViewer viewer) =>
      _guard('Could not load recommendations.', () async {
        final response = await _client.get(_isEmployee(viewer)
            ? apiEmployeeRecommendations(viewer.profileId)
            : apiCompanyRecommendations(viewer.profileId));
        return _list(response.data).map((j) => _parse(viewer, j)).toList();
      });

  @override
  Future<Set<String>> fetchLikedIds(FeedViewer viewer) =>
      _guard('Could not load your likes.', () async {
        final response = await _client.get(_isEmployee(viewer)
            ? apiEmployeeLiked(viewer.profileId)
            : apiCompanyLiked(viewer.profileId));
        return _list(response.data).map((j) => '${j['id']}').toSet();
      });

  @override
  Future<Map<String, String>> fetchFavorites(FeedViewer viewer) =>
      _guard('Could not load your saved profiles.', () async {
        final response = await _client.get(_isEmployee(viewer)
            ? apiEmployeeFavorites(viewer.profileId)
            : apiCompanyFavorites(viewer.profileId));
        // Each entry is `{ id: favoriteId, company | employee: { id, ... } }`.
        final key = _isEmployee(viewer) ? 'company' : 'employee';
        return {
          for (final entry in _list(response.data))
            if (entry[key] is Map && entry['id'] != null)
              '${(entry[key] as Map)['id']}': '${entry['id']}',
        };
      });

  @override
  Future<Set<String>> fetchHiddenIds() =>
      _guard('Could not load blocked profiles.', () async {
        final response = await _client.get(apiHiddenProfileIds);
        final data = response.data;
        return data is List ? data.map((id) => '$id').toSet() : <String>{};
      });

  @override
  Future<int> fetchUnreadNotificationCount() =>
      _guard('Could not load notifications.', () async {
        final response = await _client.get(apiNotificationUnreadCount);
        final data = response.data;
        final count = data is Map ? data['unreadCount'] : null;
        return count is int ? count : 0;
      });

  @override
  Future<bool> like(FeedViewer viewer, String profileId) =>
      _guard('Could not send your like. Please try again.', () async {
        final response = await _client.post(_isEmployee(viewer)
            ? apiEmployeeLikesCompany(viewer.profileId, profileId)
            : apiCompanyLikesEmployee(viewer.profileId, profileId));
        final data = response.data;
        return data is Map && data['isMatched'] == true;
      });

  @override
  Future<void> favorite(FeedViewer viewer, String profileId) =>
      _guard('Could not save this profile. Please try again.', () async {
        await _client.post(_isEmployee(viewer)
            ? apiEmployeeFavoriteCompany(viewer.profileId, profileId)
            : apiCompanyFavoriteEmployee(viewer.profileId, profileId));
      });

  @override
  Future<void> unfavorite(
    FeedViewer viewer,
    String profileId,
    String favoriteId,
  ) =>
      _guard('Could not remove this profile. Please try again.', () async {
        await _client.post(_isEmployee(viewer)
            ? apiEmployeeUnfavoriteCompany(viewer.profileId, profileId, favoriteId)
            : apiCompanyUnfavoriteEmployee(viewer.profileId, profileId, favoriteId));
      });

  static Iterable<Map<String, dynamic>> _list(dynamic data) => data is List
      ? data.whereType<Map>().map((m) => m.cast<String, dynamic>())
      : const [];

  Future<T> _guard<T>(String fallback, Future<T> Function() body) async {
    try {
      return await body();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: fallback);
    }
  }
}
