import 'package:apsaratalent_mobile/core/constants/apis/match_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/match/domain/entities/match_profile.dart';
import 'package:apsaratalent_mobile/features/match/domain/repositories/match_repository.dart';

class MatchRepositoryImpl implements MatchRepository {
  MatchRepositoryImpl(this._client);

  final ApiClient _client;

  bool _isEmployee(FeedViewer viewer) => viewer.role == FeedViewerRole.employee;

  @override
  Future<List<MatchProfile>> fetchMatches(FeedViewer viewer) =>
      _guard('Could not load your matches.', () async {
        final employee = _isEmployee(viewer);
        final response = await _client.get(employee
            ? apiEmployeeMatches(viewer.profileId)
            : apiCompanyMatches(viewer.profileId));
        final data = response.data;
        if (data is! List) return const <MatchProfile>[];
        return data
            .whereType<Map>()
            .map((m) => MatchProfile.fromJson(
                  m.cast<String, dynamic>(),
                  viewerIsEmployee: employee,
                ))
            .toList();
      });

  @override
  Future<MatchCount> fetchCount(FeedViewer viewer) =>
      _guard('Could not load your match count.', () async {
        final response = await _client.get(_isEmployee(viewer)
            ? apiEmployeeMatchCount(viewer.profileId)
            : apiCompanyMatchCount(viewer.profileId));
        return _count(response.data);
      });

  @override
  Future<MatchCount> markSeen(FeedViewer viewer) =>
      _guard('Could not mark your matches seen.', () async {
        final response = await _client.post(_isEmployee(viewer)
            ? apiEmployeeMatchesSeen(viewer.profileId)
            : apiCompanyMatchesSeen(viewer.profileId));
        return _count(response.data);
      });

  @override
  Future<void> unmatch(FeedViewer viewer, String profileId) =>
      _guard('Could not end this match. Please try again.', () async {
        // The route is always employee id then company id, whichever side is
        // asking — so the viewer's own id is not always the first one.
        final employee = _isEmployee(viewer);
        await _client.delete(
          apiUnmatch(
            employee ? viewer.profileId : profileId,
            employee ? profileId : viewer.profileId,
          ),
        );
      });

  MatchCount _count(dynamic data) => data is Map
      ? MatchCount.fromJson(data.cast<String, dynamic>())
      : MatchCount.empty;

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
