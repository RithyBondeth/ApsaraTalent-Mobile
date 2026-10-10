import 'dart:io';
import 'package:apsaratalent_mobile/app/app.dart';
import 'package:apsaratalent_mobile/core/configs/config_service.dart';
import 'package:apsaratalent_mobile/core/enums/environment_enum.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/setting/providers/locale_provider.dart';
import 'package:apsaratalent_mobile/features/resume_builder/data/resume_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Native UI + real gateway. The browser acceptance runner creates this draft,
// then checks the mobile edit in the browser after this test completes.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  const enabled = bool.fromEnvironment('LOCAL_ACCEPTANCE');
  const base = String.fromEnvironment('ACCEPTANCE_API_BASE_URL',
      defaultValue: 'http://127.0.0.1:13000');
  const draftName = String.fromEnvironment('ACCEPTANCE_DRAFT_NAME',
      defaultValue: 'Local shared resume');
  const browserText = String.fromEnvironment('ACCEPTANCE_BROWSER_TEXT',
      defaultValue:
          'A local fixture for testing shared web/mobile resume drafts.');
  const mobileText = String.fromEnvironment('ACCEPTANCE_MOBILE_TEXT',
      defaultValue: 'Edited in the native acceptance journey.');

  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    final end = DateTime.now().add(const Duration(seconds: 40));
    while (finder.evaluate().isEmpty && DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(finder, findsWidgets);
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 20));
  }

  var surfaceConverted = false;
  Future<void> screenshot(WidgetTester tester, String name) async {
    if (Platform.isAndroid && !surfaceConverted) {
      await binding.convertFlutterSurfaceToImage();
      surfaceConverted = true;
      await tester.pump();
    }
    final bytes = await binding.takeScreenshot(name);
    await File('${Directory.systemTemp.path}/apsara-acceptance-$name.png')
        .writeAsBytes(bytes);
  }

  testWidgets(
      'real sign-in, dashboard, browser-to-native resume edit, and Khmer navigation',
      (tester) async {
    final host = Uri.parse(base).host;
    if (!['127.0.0.1', 'localhost', '10.0.2.2'].contains(host)) {
      throw StateError(
          'This fixture is restricted to the disposable loopback API.');
    }
    await AppConfigService.initialize(EEnvironmentType.development);
    dotenv.loadFromString(
        envString: 'APP_NAME=Apsara Talent QA\nAPI_BASE_URL=$base');
    final session = SessionStore();
    await session.clear();
    final container = ProviderContainer(
        overrides: [sessionStoreProvider.overrideWithValue(session)]);
    addTearDown(container.dispose);
    await container.read(localeProvider.notifier).setLocale(const Locale('en'));
    await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const App()));
    await waitFor(tester, find.text('Log in to your account'));
    final inputs = find.byType(EditableText);
    await tester.enterText(inputs.at(0), 'candidate@local.test');
    await tester.enterText(inputs.at(1), 'LocalTest!12345');
    FocusManager.instance.primaryFocus?.unfocus();
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    await tester.pump();
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await waitFor(tester, find.text('Dashboard'));
    await screenshot(tester, 'feed');
    await tester.tap(find.text('Dashboard'));
    await waitFor(tester, find.text('Your activity at a glance'));
    await waitFor(tester, find.text('Weekly activity'));
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resume'));
    await waitFor(tester, find.text('My resumes'));
    await tester.tap(find.text('My resumes'));
    await waitFor(tester, find.text(draftName));
    await tester.tap(find.text(draftName));
    await waitFor(tester, find.text(browserText));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Summary'));
    await tester.tap(find.text('Summary'));
    await waitFor(tester, find.byType(AlertDialog));
    await tester.enterText(find.byType(EditableText), mobileText);
    FocusManager.instance.primaryFocus?.unfocus();
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await waitFor(tester, find.text('Saved to your account'));
    final repository = ResumeRepository(container.read(apiClientProvider));
    final metadata = (await repository.drafts())
        .singleWhere((draft) => draft['name'] == draftName);
    final saved = await repository.draft(metadata['id'] as String);
    expect((saved['content'] as Map)['summary'], mobileText);
    expect((saved['content'] as Map)['design'], isNotNull);

    await container.read(localeProvider.notifier).setLocale(const Locale('km'));
    await tester.pumpAndSettle();
    expect(find.text('ការកំណត់'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await screenshot(tester, 'khmer-resume');
    await tester.pumpWidget(const SizedBox.shrink());
    await session.clear();
  }, skip: !enabled);
}
