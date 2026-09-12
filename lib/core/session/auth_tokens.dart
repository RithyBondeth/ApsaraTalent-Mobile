/// The access/refresh pair the API issues on every sign-in and refresh.
///
/// The API never puts these in a response body — its web client keeps them in
/// httpOnly cookies, out of reach of page scripts, and the gateway enforces
/// that boundary in `auth-token-boundary.spec.ts`. They arrive as `Set-Cookie`
/// headers, which a native client can read even though a browser script cannot.
/// See [AuthCookies].
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  @override
  bool operator ==(Object other) =>
      other is AuthTokens &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken;

  @override
  int get hashCode => Object.hash(accessToken, refreshToken);

  /// Never print the values — this ends up in logs.
  @override
  String toString() => 'AuthTokens(<redacted>)';
}
