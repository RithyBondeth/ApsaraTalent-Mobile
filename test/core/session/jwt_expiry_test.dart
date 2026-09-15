import 'dart:convert';

import 'package:apsaratalent_mobile/core/session/jwt_expiry.dart';
import 'package:flutter_test/flutter_test.dart';

String jwtExpiringAt(DateTime at) {
  String part(Map<String, Object> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.'
      '${part({'exp': at.millisecondsSinceEpoch ~/ 1000})}.signature';
}

void main() {
  final now = DateTime.utc(2026, 9, 15, 12);

  test('a token expiring later is not expired', () {
    expect(isJwtExpired(jwtExpiringAt(now.add(const Duration(hours: 1))), now: now), isFalse);
  });

  test('a token past its exp is expired', () {
    expect(isJwtExpired(jwtExpiringAt(now.subtract(const Duration(minutes: 1))), now: now), isTrue);
  });

  test('a token inside the skew window counts as expired', () {
    expect(isJwtExpired(jwtExpiringAt(now.add(const Duration(seconds: 10))), now: now), isTrue);
  });

  test('anything unreadable counts as expired, so refresh stays the fallback', () {
    expect(isJwtExpired('not.a.jwt', now: now), isTrue);
    expect(isJwtExpired('garbage', now: now), isTrue);
  });
}
