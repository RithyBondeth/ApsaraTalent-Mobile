import 'package:apsaratalent_mobile/core/session/auth_cookies.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:dio/dio.dart';

enum RefreshOutcome {
  /// A new pair is in the store.
  refreshed,

  /// The API refused the refresh token (400/401/403). The session is over.
  rejected,

  /// The API couldn't be asked — offline, timed out, throttled, or a 5xx. The
  /// session may be perfectly good; don't sign anyone out over it.
  unavailable,
}

/// Exchanges the refresh token for a new pair, at most one exchange at a time.
///
/// Single-flight is not an optimisation here, it is correctness. The API stores
/// one refresh-token digest per user and rotates it on every refresh, so the
/// presented token dies the moment it is used. If a screen fires three requests
/// that all come back 401, three independent refreshes would send the same
/// token three times: the first wins and the other two are refused — which
/// reads as "session rejected" and signs the user out. Concurrent callers
/// therefore share the one in-flight exchange.
///
/// It also matters for the rate limit: `/auth/refresh` is on the credential
/// budget of 5 requests a minute.
class TokenRefresher {
  TokenRefresher({required Dio dio, required SessionStore store})
      : _dio = dio,
        _store = store;

  /// A Dio with no session interceptor. The refresh call must not itself be
  /// eligible for "401 → refresh", or a refused refresh would recurse.
  final Dio _dio;
  final SessionStore _store;

  static const path = '/auth/refresh';

  Future<RefreshOutcome>? _inFlight;

  Future<RefreshOutcome> refresh() {
    return _inFlight ??= _exchange().whenComplete(() => _inFlight = null);
  }

  Future<RefreshOutcome> _exchange() async {
    final refreshToken = _store.refreshToken;
    if (refreshToken == null) return RefreshOutcome.rejected;

    try {
      // In the body, not as a cookie: a cookie-carrying write with no Origin
      // header is refused by the gateway's CSRF check.
      final response = await _dio.post<dynamic>(
        path,
        data: {'refreshToken': refreshToken},
      );
      final tokens = AuthCookies.read(response.headers);
      if (tokens == null) return RefreshOutcome.rejected;
      await _store.rotate(tokens);
      return RefreshOutcome.refreshed;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400 || status == 401 || status == 403) {
        return RefreshOutcome.rejected;
      }
      return RefreshOutcome.unavailable;
    }
  }
}
