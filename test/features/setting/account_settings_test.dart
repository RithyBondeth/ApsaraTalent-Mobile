import 'dart:convert';

import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/setting/data/repositories/account_settings_repository.dart';
import 'package:apsaratalent_mobile/features/setting/domain/entities/account_settings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  AccountSettingsRepository repositoryFor(FakeHttp http) =>
      AccountSettingsRepository(ApiClient(
        sessionStore: SessionStore(),
        baseUrl: 'http://api.test',
        adapter: http,
      ));

  test('loads profile analytics and recent viewers', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {
          'profileViews7d': 4,
          'profileViews30d': 12,
          'searchAppearances30d': 30,
          'browsePrivately': true,
          'recentViewers': [
            {
              'viewerName': 'Sokha',
              'viewerRole': 'company',
              'viewedAt': '2026-09-27T00:00:00Z'
            }
          ],
        }));

    final result = await repositoryFor(http).fetchProfileAnalytics();

    expect(http.requests.single.path, '/user/me/profile-analytics');
    expect(result.browsePrivately, isTrue);
    expect(result.recentViewers.single.name, 'Sokha');
  });

  test('privacy update sends the persisted boolean', () async {
    final http =
        FakeHttp((_) async => jsonResponse(200, {'browsePrivately': true}));

    expect(await repositoryFor(http).updatePrivacy(true), isTrue);
    expect(http.requests.single.method, 'PATCH');
    expect(http.requests.single.data, {'browsePrivately': true});
  });

  test('support report matches the API category and details contract',
      () async {
    final http =
        FakeHttp((_) async => jsonResponse(201, {'message': 'Received'}));

    final message = await repositoryFor(http).reportProblem(
      category: ProblemCategory.account,
      details: '  Cannot change my email  ',
      userAgent: 'android',
    );

    expect(message, 'Received');
    expect(http.requests.single.path, '/user/support/report-problem');
    expect(http.requests.single.data, {
      'category': 'account',
      'details': 'Cannot change my email',
      'userAgent': 'android',
    });
  });

  test('export preserves bytes and the server filename', () async {
    final bytes = utf8.encode('{"exportedAt":"now"}');
    final http =
        FakeHttp((_) async => ResponseBody.fromBytes(bytes, 200, headers: {
              Headers.contentTypeHeader: ['application/json'],
              'content-disposition': [
                'attachment; filename="apsara-export.json"'
              ],
            }));

    final result = await repositoryFor(http).exportData();

    expect(result.fileName, 'apsara-export.json');
    expect(utf8.decode(result.bytes), '{"exportedAt":"now"}');
    expect(http.requests.single.responseType, ResponseType.bytes);
  });

  test('request and cancellation use the account lifecycle routes', () async {
    final http = FakeHttp((request) async {
      if (request.path.endsWith('/cancel')) {
        return jsonResponse(201, {'message': 'Cancelled'});
      }
      return jsonResponse(201, {
        'message': 'Scheduled',
        'scheduledFor': '2026-10-28T00:00:00.000Z',
      });
    });
    final repository = repositoryFor(http);

    final scheduled = await repository.requestDeletion();
    expect(scheduled.scheduledFor, DateTime.utc(2026, 10, 28));
    expect(await repository.cancelDeletion(), 'Cancelled');
    expect(http.requests.map((r) => r.path), [
      '/user/account/delete',
      '/user/account/delete/cancel',
    ]);
  });
}
