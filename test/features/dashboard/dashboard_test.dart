import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/fake_http.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  for (final role in FeedViewerRole.values) {
    test(
        '${role.name} dashboard uses profile ID and the real matchedAt contract',
        () async {
      final http = FakeHttp((_) async => jsonResponse(200, {
            'totalLikesGiven': 10,
            'totalLikesReceived': 8,
            'totalMatches': 3,
            'matchRate': 30,
            'totalFavorites': 2,
            'monthlyActivity': [],
            'weeklyActivity': [
              {'day': 'Mon', 'likes': 1, 'received': 2, 'matches': 1}
            ],
            'recentMatches': [
              {
                'id': 'peer',
                'name': 'Peer',
                'avatar': null,
                'matchedAt': '2026-10-08T00:00:00Z'
              }
            ],
          }));
      final data = await DashboardRepository(ApiClient(
              sessionStore: SessionStore(),
              baseUrl: 'http://api.test',
              adapter: http))
          .fetch(FeedViewer(role: role, profileId: 'profile-id'));
      expect(http.requests.single.path, '/match/analytics/profile-id');
      expect(http.requests.single.queryParameters, {'role': role.name});
      expect(data.recentMatches.single.matchedAt, '2026-10-08T00:00:00Z');
      expect(data.weeklyActivity.single.received, 2);
      expect(data.totalFavorites, 2);
    });
  }
}
