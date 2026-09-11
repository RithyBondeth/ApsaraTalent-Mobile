import 'package:apsaratalent_mobile/core/session/auth_cookies.dart';
import 'package:apsaratalent_mobile/core/session/auth_tokens.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

Headers _headers(List<String> setCookies) =>
    Headers.fromMap({'set-cookie': setCookies});

void main() {
  test('reads the pair the gateway sets', () {
    expect(
      AuthCookies.read(_headers(authCookies('a.b.c', 'r.s.t'))),
      const AuthTokens(accessToken: 'a.b.c', refreshToken: 'r.s.t'),
    );
  });

  test('keeps "=" inside a value (base64 padding)', () {
    final tokens = AuthCookies.read(_headers([
      'auth-token=abc==; Path=/',
      'refresh-token=def=; Path=/',
    ]));
    expect(tokens?.accessToken, 'abc==');
    expect(tokens?.refreshToken, 'def=');
  });

  test('is null when either cookie is missing', () {
    expect(AuthCookies.read(_headers(['auth-token=abc; Path=/'])), isNull);
    expect(AuthCookies.read(Headers()), isNull);
  });

  test('treats the cleared cookies logout sends as absent, not as tokens', () {
    final cleared = [
      'auth-token=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT',
      'refresh-token=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT',
    ];
    expect(AuthCookies.read(_headers(cleared)), isNull);
  });

  test('ignores unrelated cookies', () {
    final tokens = AuthCookies.read(_headers([
      'auth-remember=true; Path=/',
      ...authCookies('a', 'r'),
    ]));
    expect(tokens, const AuthTokens(accessToken: 'a', refreshToken: 'r'));
  });
}
