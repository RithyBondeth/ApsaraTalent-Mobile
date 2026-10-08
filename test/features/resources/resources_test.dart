import 'dart:convert';
import 'dart:io';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import '../../support/fake_http.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/resources/presentation/resources_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test('six resource documents preserve the web English/Khmer source catalog',
      () {
    final catalog =
        jsonDecode(File('assets/public_content.json').readAsStringSync())
            as Map;
    final docs = catalog['documents'] as Map;
    expect(
        docs.keys,
        containsAll(
            ['terms', 'privacy', 'product', 'learn', 'safety', 'support']));
    expect((catalog['sourceHashes'] as Map).length, 6);
    for (final doc in docs.values) {
      expect(doc['en']['pageTitle'], isNotEmpty);
      expect(doc['km']['pageTitle'], isNotEmpty);
      expect(doc['en']['pageTitle'], isNot(doc['km']['pageTitle']));
    }
  });
  test('public community counts use the shared gateway without a session',
      () async {
    final http = FakeHttp((_) async =>
        jsonResponse(200, {'users': 4, 'companies': 1, 'employees': 2}));
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(ApiClient(
          sessionStore: SessionStore(),
          baseUrl: 'http://api.test',
          adapter: http))
    ]);
    addTearDown(container.dispose);
    final stats = await container.read(communityStatsProvider.future);
    expect(stats.users, 4);
    expect(stats.companies, 1);
    expect(http.requests.single.path, '/public/user/landing-stats');
    expect(http.requests.single.headers['Authorization'], isNull);
  });
  testWidgets('support FAQs expand while signed out', (tester) async {
    await tester.pumpWidget(ProviderScope(
        overrides: [
          publicContentProvider.overrideWith((ref) async =>
              Map<String, dynamic>.from((jsonDecode(
                      File('assets/public_content.json').readAsStringSync())
                  as Map)['documents'] as Map))
        ],
        child: MaterialApp(
            theme: AppTheme.light(),
            home: const ResourcesScreen(document: 'support'))));
    await tester.pumpAndSettle();
    final faq = find.byType(ExpansionTile).first;
    await tester.ensureVisible(faq);
    await tester.tap(faq);
    await tester.pumpAndSettle();
    expect(tester.widget<ExpansionTile>(faq).title, isA<Text>());
    expect(tester.takeException(), isNull);
  });
  testWidgets('legal document follows restored Khmer language', (tester) async {
    FlutterSecureStorage.setMockInitialValues({'preferences.locale': 'km'});
    await tester.pumpWidget(ProviderScope(
        overrides: [
          publicContentProvider.overrideWith((ref) async =>
              Map<String, dynamic>.from((jsonDecode(
                      File('assets/public_content.json').readAsStringSync())
                  as Map)['documents'] as Map))
        ],
        child: MaterialApp(
            theme: AppTheme.light(),
            home: const ResourcesScreen(document: 'terms'))));
    await tester.pumpAndSettle();
    final docs =
        (jsonDecode(File('assets/public_content.json').readAsStringSync())
            as Map)['documents'];
    expect(
        find.text(docs['terms']['km']['pageTitle'] as String), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
