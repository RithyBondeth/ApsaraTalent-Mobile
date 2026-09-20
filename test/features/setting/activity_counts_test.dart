import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/setting/data/repositories/activity_counts_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

void main() {
  const employee = FeedViewer(role: FeedViewerRole.employee, profileId: 'e1');
  const company = FeedViewer(role: FeedViewerRole.company, profileId: 'c1');

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  ActivityCountsRepository repositoryFor(FakeHttp http) =>
      ActivityCountsRepository(
        ApiClient(
          sessionStore: SessionStore(),
          baseUrl: 'http://api.test',
          adapter: http,
        ),
      );

  /// Answers each of the three routes with the real response shape.
  FakeHttp stack({
    dynamic applications = const [<String, dynamic>{}, <String, dynamic>{}],
    dynamic saved = const {'count': 2},
    dynamic unread = const {'unreadCount': 1},
  }) =>
      FakeHttp((request) async {
        if (request.path.contains('application/mine')) {
          return jsonResponse(200, applications);
        }
        if (request.path.contains('count-favorite')) {
          return jsonResponse(200, saved);
        }
        return jsonResponse(200, unread);
      });

  test('reads all three counts from their own routes', () async {
    final http = stack();

    final counts = await repositoryFor(http).fetch(employee);

    expect(counts.applications, 2);
    expect(counts.saved, 2);
    expect(counts.unread, 1);
    expect(http.requests, hasLength(3));
  });

  test('a company asks the company favourite route', () async {
    final http = stack();

    await repositoryFor(http).fetch(company);

    expect(
      http.requests.map((r) => r.path),
      contains('/user/company/count-favorite/c1'),
    );
  });

  test('one failing count does not take the others down', () async {
    // Nothing here should be able to stop the settings page opening.
    final http = FakeHttp((request) async {
      if (request.path.contains('count-favorite')) {
        return jsonResponse(500, {'message': 'boom'});
      }
      if (request.path.contains('application/mine')) {
        return jsonResponse(200, [<String, dynamic>{}]);
      }
      return jsonResponse(200, {'unreadCount': 4});
    });

    final counts = await repositoryFor(http).fetch(employee);

    // Null, not zero: "not known" is a different statement from "none".
    expect(counts.saved, isNull);
    expect(counts.applications, 1);
    expect(counts.unread, 4);
  });

  test('a malformed body reads as unknown rather than zero', () async {
    final http = stack(saved: 'nope', unread: <String, dynamic>{});

    final counts = await repositoryFor(http).fetch(employee);

    expect(counts.saved, isNull);
    expect(counts.unread, isNull);
  });
}
