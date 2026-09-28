import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/push/push_bootstrap.dart';
import 'package:apsaratalent_mobile/core/push/push_token_service.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

class FakePushMessaging implements PushMessagingClient {
  bool allowed = true;
  String? currentToken = 'device-token-long-enough';
  bool deleted = false;

  @override
  Future<bool> authorize() async => allowed;

  @override
  Future<void> deleteToken() async => deleted = true;

  @override
  Future<String?> token() async => currentToken;
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    PushBootstrap.available = true;
  });
  tearDown(() => PushBootstrap.available = false);

  PushTokenService serviceFor(FakeHttp http, FakePushMessaging messaging) =>
      PushTokenService(
        ApiClient(
          sessionStore: SessionStore(),
          baseUrl: 'http://api.test',
          adapter: http,
        ),
        messaging: messaging,
      );

  test('registers an authorized Firebase token once', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {'success': true}));
    final messaging = FakePushMessaging();
    final service = serviceFor(http, messaging);

    await service.register();
    await service.register();

    expect(http.requests, hasLength(1));
    expect(http.requests.single.method, 'PUT');
    expect(http.requests.single.path, '/notification/device-token');
    expect(http.requests.single.data, {
      'token': 'device-token-long-enough',
    });
  });

  test('does not request registration after permission is denied', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {'success': true}));
    final messaging = FakePushMessaging()..allowed = false;

    await serviceFor(http, messaging).register();

    expect(http.requests, isEmpty);
  });

  test('removes the exact token and deletes it locally on sign-out', () async {
    final http = FakeHttp((_) async => jsonResponse(200, {'success': true}));
    final messaging = FakePushMessaging();
    final service = serviceFor(http, messaging);
    await service.register();
    http.requests.clear();

    await service.unregister();

    expect(http.requests.single.method, 'DELETE');
    expect(http.requests.single.data, {
      'token': 'device-token-long-enough',
    });
    expect(messaging.deleted, isTrue);
  });
}
