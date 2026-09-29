import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _localeStorageKey = 'preferences.locale';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(const Locale('en')) {
    _restore();
  }

  final FlutterSecureStorage _storage;
  var _changeRevision = 0;

  Future<void> _restore() async {
    final revision = _changeRevision;
    try {
      final code = await _storage.read(key: _localeStorageKey);
      if (revision == _changeRevision && (code == 'en' || code == 'km')) {
        state = Locale(code!);
      }
    } catch (_) {
      // A preference failure must never stop the app from launching in English.
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'en' && locale.languageCode != 'km') return;
    _changeRevision++;
    state = Locale(locale.languageCode);
    await _storage.write(key: _localeStorageKey, value: locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
