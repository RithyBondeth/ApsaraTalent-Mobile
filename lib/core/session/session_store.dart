import 'dart:async';

import 'package:apsaratalent_mobile/core/session/auth_tokens.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the signed-in user's tokens live.
///
/// "Remember me" picks between two lifetimes, the same split the web app makes
/// between localStorage and sessionStorage:
///
///  * **remembered** — written to the Keychain (iOS) / Keystore-backed storage
///    (Android) and restored on the next launch;
///  * **not remembered** — held in memory only, so the session ends when the
///    process does.
///
/// Keychain items use `first_unlock_this_device`: readable after the first
/// unlock since boot (so a background refresh works), never synced to iCloud
/// Keychain and never migrated to another device through a backup. A refresh
/// token is a 30-day credential; it should not follow a backup onto a phone the
/// user has sold.
///
/// One known gap: iOS keeps Keychain items when an app is deleted, so a
/// remembered session survives an uninstall and reinstall. Closing that needs a
/// first-launch marker outside the Keychain.
class SessionStore {
  SessionStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _accessKey = 'auth.accessToken';
  static const _refreshKey = 'auth.refreshToken';

  AuthTokens? _tokens;
  bool _remembered = false;

  final StreamController<void> _expirations =
      StreamController<void>.broadcast();

  /// Fires when the API refuses the session outright — a refresh answered 401,
  /// 400 or 403. The network layer lives in core and cannot reach the auth
  /// feature, so it reports through here and the auth feature listens.
  Stream<void> get expirations => _expirations.stream;

  AuthTokens? get tokens => _tokens;
  String? get accessToken => _tokens?.accessToken;
  String? get refreshToken => _tokens?.refreshToken;
  bool get hasSession => _tokens != null;

  /// Whether the current session is written to secure storage. A refresh keeps
  /// whichever lifetime the sign-in chose.
  bool get isRemembered => _remembered;

  /// Loads a remembered session into memory. Call once at launch.
  Future<AuthTokens?> restore() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) {
      // A half-written pair is unusable; don't leave the other half behind.
      if (access != null || refresh != null) await _wipeStorage();
      return null;
    }
    _tokens = AuthTokens(accessToken: access, refreshToken: refresh);
    _remembered = true;
    return _tokens;
  }

  Future<void> save(AuthTokens tokens, {required bool remember}) async {
    _tokens = tokens;
    _remembered = remember;
    if (remember) {
      await _storage.write(key: _accessKey, value: tokens.accessToken);
      await _storage.write(key: _refreshKey, value: tokens.refreshToken);
    } else {
      // Signing in without "remember me" must not leave an earlier remembered
      // session on disk to be restored next launch.
      await _wipeStorage();
    }
  }

  /// Replaces the pair after a refresh, keeping the lifetime the sign-in chose.
  Future<void> rotate(AuthTokens tokens) => save(tokens, remember: _remembered);

  /// Ends a session the server has refused, and says so on [expirations].
  Future<void> expire() async {
    await clear();
    _expirations.add(null);
  }

  Future<void> clear() async {
    _tokens = null;
    _remembered = false;
    await _wipeStorage();
  }

  Future<void> _wipeStorage() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
