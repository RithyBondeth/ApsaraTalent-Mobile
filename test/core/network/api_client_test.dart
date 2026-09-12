import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('normalizeBaseUrl drops trailing slashes', () {
    expect(ApiClient.normalizeBaseUrl('https://api.example.com/'),
        'https://api.example.com');
    expect(ApiClient.normalizeBaseUrl(' http://127.0.0.1:3000// '),
        'http://127.0.0.1:3000');
    expect(ApiClient.normalizeBaseUrl('http://127.0.0.1:3000'),
        'http://127.0.0.1:3000');
  });

  test('messageFrom joins a validation list instead of crashing on it', () {
    expect(
      ApiClient.messageFrom({
        'message': ['identifier should not be empty', 'identifier must be a string'],
      }),
      'identifier should not be empty\nidentifier must be a string',
    );
    expect(ApiClient.messageFrom({'message': 'Invalid credentials'}),
        'Invalid credentials');
    expect(ApiClient.messageFrom('not a map'), isNull);
  });

  Future<ApiException> errorFor(int status, Object body) async {
    final client = ApiClient(
      sessionStore: SessionStore(),
      baseUrl: 'http://api.test',
      adapter: FakeHttp((_) async => jsonResponse(status, body)),
    );
    try {
      await client.get('/anything');
    } on ApiException catch (e) {
      return e;
    }
    fail('expected an ApiException');
  }

  test('a 400 validation list becomes one readable message', () async {
    final error = await errorFor(400, {
      'message': ['identifier should not be empty'],
      'statusCode': 400,
    });
    expect(error.message, 'identifier should not be empty');
    expect(error.statusCode, 400);
  });

  test('a 429 never shows the throttler\'s own text', () async {
    final error = await errorFor(429, {
      'message': 'ThrottlerException: Too Many Requests',
    });
    expect(error.message, isNot(contains('Throttler')));
    expect(error.statusCode, 429);
  });
}
