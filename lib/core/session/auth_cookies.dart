import 'package:apsaratalent_mobile/core/session/auth_tokens.dart';
import 'package:dio/dio.dart';

/// Reads the API's auth cookies out of a response's `Set-Cookie` headers.
///
/// The gateway sets `auth-token` and `refresh-token` as httpOnly cookies on
/// login, OTP login, two-factor verification and refresh. This app does **not**
/// keep a cookie jar and send them back: a cookie-carrying write with no
/// `Origin` header is exactly what the gateway's CSRF check refuses. Instead it
/// lifts the two values out here, keeps them in the Keychain, sends the access
/// token as `Authorization: Bearer` (which `AuthGuard` accepts), and presents
/// the refresh token in the refresh request's body.
class AuthCookies {
  const AuthCookies._();

  static const accessCookie = 'auth-token';
  static const refreshCookie = 'refresh-token';

  /// The pair from [headers], or `null` if either is missing or was cleared.
  ///
  /// Logout answers with the same cookie names set to an empty value and an
  /// expiry in 1970; an empty value is treated as absent, never as a token.
  static AuthTokens? read(Headers headers) {
    final cookies = headers.map['set-cookie'] ?? const <String>[];
    String? access;
    String? refresh;

    for (final cookie in cookies) {
      final pair = cookie.split(';').first;
      final separator = pair.indexOf('=');
      if (separator <= 0) continue;

      final name = pair.substring(0, separator).trim();
      final value = pair.substring(separator + 1).trim();
      if (value.isEmpty) continue;

      if (name == accessCookie) access = value;
      if (name == refreshCookie) refresh = value;
    }

    if (access == null || refresh == null) return null;
    return AuthTokens(accessToken: access, refreshToken: refresh);
  }
}
