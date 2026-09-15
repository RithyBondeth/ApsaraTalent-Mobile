import 'dart:convert';

import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/api_interceptors.dart';
import 'package:apsaratalent_mobile/core/session/auth_tokens.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

String _jwt(Duration fromNow) {
  String part(Map<String, Object> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final exp = DateTime.now().add(fromNow).millisecondsSinceEpoch ~/ 1000;
  return '${part({'alg': 'HS256'})}.${part({'exp': exp})}.sig';
}

void main() {
  late SessionStore store;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    store = SessionStore();
  });

  /// `/auth/2fa/enable` refuses every code with 401 "Invalid code".
  FakeHttp api() => FakeHttp((r) async {
        if (r.path == '/auth/refresh') {
          return jsonResponse(200, {'message': 'ok'},
              setCookies: authCookies(_jwt(const Duration(hours: 1)), 'refresh-2'));
        }
        return jsonResponse(401, {'message': 'Invalid code. Please try again.'});
      });

  Future<Object?> enable(FakeHttp http) async {
    final client = ApiClient(sessionStore: store, baseUrl: 'http://api.test', adapter: http);
    try {
      await client.post('/auth/2fa/enable',
          data: {'otp': '000000'},
          options: Options(extra: SessionInterceptor.businessRejections));
      return null;
    } catch (e) {
      return e;
    }
  }

  test('a wrong code on a live session is returned as-is, with no refresh', () async {
    await store.save(
      AuthTokens(accessToken: _jwt(const Duration(hours: 1)), refreshToken: 'refresh-1'),
      remember: true,
    );
    final http = api();

    final error = await enable(http);

    expect(error, isA<UnauthorizedException>()
        .having((e) => e.message, 'message', 'Invalid code. Please try again.'));
    expect(http.to('/auth/refresh'), isEmpty,
        reason: 'refreshing would rotate the only refresh token for nothing');
    expect(http.to('/auth/2fa/enable'), hasLength(1),
        reason: 'replaying would submit the same wrong code twice');
    expect(store.refreshToken, 'refresh-1');
  });

  test('a genuinely expired token still refreshes', () async {
    await store.save(
      AuthTokens(accessToken: _jwt(const Duration(hours: -1)), refreshToken: 'refresh-1'),
      remember: true,
    );
    final http = api();

    await enable(http);

    expect(http.to('/auth/refresh'), hasLength(1));
    expect(store.refreshToken, 'refresh-2');
  });
}
