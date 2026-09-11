import 'package:apsaratalent_mobile/core/session/auth_tokens.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _pair = AuthTokens(accessToken: 'access', refreshToken: 'refresh');
const _next = AuthTokens(accessToken: 'access-2', refreshToken: 'refresh-2');

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('a remembered session survives into the next launch', () async {
    await SessionStore().save(_pair, remember: true);

    final nextLaunch = SessionStore();
    expect(await nextLaunch.restore(), _pair);
    expect(nextLaunch.isRemembered, isTrue);
  });

  test('an unremembered session lives in memory only', () async {
    final store = SessionStore();
    await store.save(_pair, remember: false);

    expect(store.tokens, _pair);
    expect(await SessionStore().restore(), isNull);
  });

  test('signing in without "remember me" wipes an older remembered session',
      () async {
    await SessionStore().save(_pair, remember: true);
    await SessionStore().save(_next, remember: false);

    expect(await SessionStore().restore(), isNull);
  });

  test('a refresh keeps the lifetime the sign-in chose', () async {
    final store = SessionStore();
    await store.save(_pair, remember: true);
    await store.rotate(_next);

    expect(await SessionStore().restore(), _next);
  });

  test('a half-written pair is discarded rather than restored', () async {
    FlutterSecureStorage.setMockInitialValues({'auth.accessToken': 'orphan'});

    expect(await SessionStore().restore(), isNull);
    expect(await SessionStore().restore(), isNull);
  });

  test('expire clears the session and announces it', () async {
    final store = SessionStore();
    await store.save(_pair, remember: true);
    final announced = expectLater(store.expirations, emits(null));

    await store.expire();

    await announced;
    expect(store.hasSession, isFalse);
    expect(await SessionStore().restore(), isNull);
  });
}
