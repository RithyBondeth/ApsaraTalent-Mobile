import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/features/setting/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Khmer catalog translates product copy and preserves unknown values',
      () {
    const l10n = AppLocalizations(Locale('km'));

    expect(l10n.translate('Settings'), 'ការកំណត់');
    expect(l10n.translate('User supplied company name'),
        'User supplied company name');
  });

  test('English catalog preserves source copy', () {
    const l10n = AppLocalizations(Locale('en'));
    expect(l10n.translate('Settings'), 'Settings');
  });

  test('locale choice is restored from secure storage', () async {
    FlutterSecureStorage.setMockInitialValues({
      'preferences.locale': 'km',
    });
    final notifier = LocaleNotifier();

    await Future<void>.delayed(Duration.zero);

    expect(notifier.state, const Locale('km'));
    notifier.dispose();
  });

  test('locale choice is persisted', () async {
    FlutterSecureStorage.setMockInitialValues({});
    const storage = FlutterSecureStorage();
    final notifier = LocaleNotifier(storage: storage);

    await notifier.setLocale(const Locale('km'));

    expect(await storage.read(key: 'preferences.locale'), 'km');
    expect(notifier.state, const Locale('km'));
    notifier.dispose();
  });
}
