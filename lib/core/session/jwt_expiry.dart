import 'dart:convert';

/// Whether a JWT's `exp` has passed, read without verifying the signature.
///
/// Only ever used to decide whether a 401 means "your session lapsed" — never to
/// trust anything in the token. A token that can't be read counts as expired, so
/// the caller falls back to the ordinary refresh path.
bool isJwtExpired(
  String token, {
  DateTime? now,
  Duration skew = const Duration(seconds: 30),
}) {
  final parts = token.split('.');
  if (parts.length != 3) return true;
  try {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final exp = payload is Map ? payload['exp'] : null;
    if (exp is! num) return true;
    final expiresAt =
        DateTime.fromMillisecondsSinceEpoch((exp * 1000).round(), isUtc: true);
    return !(now ?? DateTime.now().toUtc()).add(skew).isBefore(expiresAt);
  } catch (_) {
    return true;
  }
}
