import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/core/session/token_refresher.dart';
import 'package:dio/dio.dart';

/// Attaches the session to requests, and renews it when the API says it has
/// lapsed.
///
/// On a 401 from an authenticated request it refreshes once (through the
/// single-flight [TokenRefresher]) and replays the request with the new token.
/// A request is replayed at most once, so a token the API keeps refusing cannot
/// loop.
///
/// Requests that *are* the credential exchange — login, OTP, two-factor
/// verification, registration, password reset — opt out with [publicRequest].
/// A 401 there means "wrong password", not "session lapsed", and must reach the
/// screen untouched.
///
/// Replay re-sends the original body, which works for the JSON maps this app
/// sends. A `FormData` upload cannot be re-sent once consumed; an upload that
/// can outlive a token will need its own retry.
class SessionInterceptor extends Interceptor {
  SessionInterceptor({
    required SessionStore store,
    required TokenRefresher refresher,
    required Dio dio,
  })  : _store = store,
        _refresher = refresher,
        _dio = dio;

  final SessionStore _store;
  final TokenRefresher _refresher;
  final Dio _dio;

  static const _publicKey = 'session.public';
  static const _retriedKey = 'session.retried';
  static const _tokenKey = 'session.token';

  /// Pass as `Options(extra: SessionInterceptor.publicRequest)` for a request
  /// that exchanges credentials rather than using a session.
  static const Map<String, dynamic> publicRequest = {_publicKey: true};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _store.accessToken;
    if (options.extra[_publicKey] != true && token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[_tokenKey] = token;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final usedToken = options.extra[_tokenKey] as String?;

    if (err.response?.statusCode != 401 ||
        options.extra[_publicKey] == true ||
        options.extra[_retriedKey] == true ||
        usedToken == null) {
      return handler.next(err);
    }

    // Another request may already have refreshed while this one was in the
    // air. Its token is stale but the session isn't — replay without spending
    // a refresh.
    final current = _store.accessToken;
    if (current == null || current == usedToken) {
      switch (await _refresher.refresh()) {
        case RefreshOutcome.refreshed:
          break;
        case RefreshOutcome.rejected:
          await _store.expire();
          return handler.next(err);
        case RefreshOutcome.unavailable:
          return handler.next(err);
      }
    }

    try {
      options.extra[_retriedKey] = true;
      return handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }
}
