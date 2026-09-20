import 'dart:async';

import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/api_interceptors.dart';
import 'package:apsaratalent_mobile/core/session/auth_tokens.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

const _stale = AuthTokens(accessToken: 'stale', refreshToken: 'refresh-1');

/// A tiny API: `/user/current-user` accepts only the token named in
/// [validToken]; `/auth/refresh` answers per [onRefresh].
class _Api {
  _Api({required this.onRefresh});

  String validToken = 'fresh';
  Future<ResponseBody> Function(RequestOptions r) onRefresh;
  Completer<void>? holdRefresh;

  late final http = FakeHttp((r) async {
    if (r.path == '/auth/refresh') {
      await holdRefresh?.future;
      return onRefresh(r);
    }
    final auth = r.headers['Authorization'];
    if (auth == 'Bearer $validToken') {
      return jsonResponse(200, {'id': 'user-1'});
    }
    return jsonResponse(401, {'message': 'Unauthorized'});
  });
}

Future<ResponseBody> _rotated(RequestOptions _) async =>
    jsonResponse(200, {'message': 'ok'}, setCookies: authCookies('fresh', 'refresh-2'));

void main() {
  late SessionStore store;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    store = SessionStore();
    await store.save(_stale, remember: true);
  });

  ApiClient clientFor(_Api api) => ApiClient(
        sessionStore: store,
        baseUrl: 'http://api.test/',
        adapter: api.http,
      );

  test('sends the access token as a Bearer header', () async {
    final api = _Api(onRefresh: _rotated)..validToken = 'stale';
    await clientFor(api).get('/user/current-user');

    expect(api.http.requests.single.headers['Authorization'], 'Bearer stale');
    expect(api.http.requests.single.uri.toString(),
        'http://api.test/user/current-user',
        reason: 'a trailing slash on the base URL must not double up');
  });

  test('on 401 it refreshes once, rotates the pair and replays', () async {
    final api = _Api(onRefresh: _rotated);
    final response = await clientFor(api).get('/user/current-user');

    expect(response.statusCode, 200);
    expect(store.tokens,
        const AuthTokens(accessToken: 'fresh', refreshToken: 'refresh-2'));

    final refresh = api.http.to('/auth/refresh').single;
    expect(refresh.data, {'refreshToken': 'refresh-1'},
        reason: 'the refresh token goes in the body');
    expect(refresh.headers['Cookie'], isNull,
        reason: 'a cookie-carrying write with no Origin is refused by the CSRF check');
    expect(refresh.headers['Authorization'], isNull);
  });

  test('concurrent 401s share one refresh — the API rotates on every use',
      () async {
    final api = _Api(onRefresh: _rotated)..holdRefresh = Completer<void>();
    final client = clientFor(api);

    final calls = List.generate(3, (_) => client.get('/user/current-user'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    api.holdRefresh!.complete();
    final responses = await Future.wait(calls);

    expect(responses.map((r) => r.statusCode), everyElement(200));
    expect(api.http.to('/auth/refresh'), hasLength(1));
  });

  test('a refused refresh ends the session and says so', () async {
    final api = _Api(
      onRefresh: (_) async => jsonResponse(401, {'message': 'Invalid refresh token'}),
    );
    final expired = expectLater(store.expirations, emits(null));

    await expectLater(
      clientFor(api).get('/user/current-user'),
      throwsA(isA<UnauthorizedException>()),
    );
    await expired;
    expect(store.hasSession, isFalse);
  });

  test('an unreachable refresh keeps the session — offline is not signed out',
      () async {
    for (final failure in <Future<ResponseBody> Function(RequestOptions)>[
      (_) async => jsonResponse(503, {'message': 'Service Unavailable'}),
      (_) async => jsonResponse(429, {'message': 'ThrottlerException: Too Many Requests'}),
      (r) async => throw DioException.connectionError(
            requestOptions: r,
            reason: 'offline',
          ),
    ]) {
      await store.save(_stale, remember: true);
      final api = _Api(onRefresh: failure);

      await expectLater(
        clientFor(api).get('/user/current-user'),
        throwsA(isA<ApiException>()),
      );
      expect(store.tokens, _stale);
    }
  });

  test('a replay that is still refused does not refresh again', () async {
    // Refresh "succeeds" but the API keeps rejecting the new token too.
    final api = _Api(onRefresh: _rotated)..validToken = 'never';

    await expectLater(
      clientFor(api).get('/user/current-user'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(api.http.to('/auth/refresh'), hasLength(1));
    expect(api.http.to('/user/current-user'), hasLength(2));
  });

  test('a credential exchange\'s 401 is a wrong password, not a lapsed session',
      () async {
    final http = FakeHttp((r) async =>
        jsonResponse(401, {'message': 'Invalid credentials'}));
    final client = ApiClient(
      sessionStore: store,
      baseUrl: 'http://api.test',
      adapter: http,
    );

    await expectLater(
      client.post(
        '/auth/login',
        data: {'identifier': 'x', 'password': 'y'},
        options: Options(extra: SessionInterceptor.publicRequest),
      ),
      throwsA(isA<UnauthorizedException>()
          .having((e) => e.message, 'message', 'Invalid credentials')),
    );
    expect(http.requests.single.headers['Authorization'], isNull);
    expect(http.to('/auth/refresh'), isEmpty);
    expect(store.tokens, _stale);
  });
}
