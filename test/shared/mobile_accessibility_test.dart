import 'dart:ui' show SemanticsAction, SemanticsFlag;
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/features/navigation/presentation/widgets/app_bottom_navigation.dart';
import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/feed/presentation/screens/feed_screen.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
        '${locale.languageCode}: activity actions, buttons and header support large text',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 780));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final semantics = tester.ensureSemantics();
      var dashboards = 0;
      var applications = 0;
      var notifications = 0;
      final tabs = _TestTabsRouter();
      await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
            bottomNavigationBar: AppBottomNavigation(tabsRouter: tabs),
            body: AppScreen(
              appBar: AppHeader(
                  name: 'A very long candidate name',
                  subtitle: 'Software engineer',
                  unreadCount: 123,
                  matchCount: 12,
                  onProfileTap: () {},
                  onMatchesTap: () {},
                  onNotificationsTap: () => notifications++),
              children: [
                FeedQuickActions(
                    onDashboard: () => dashboards++,
                    onApplications: () => applications++),
                AppButton(
                    label: 'Manage notification settings',
                    fullWidth: true,
                    onPressed: () {}),
                const PageBanner(
                    eyebrow: 'Dashboard',
                    title: 'Your activity at a glance',
                    stats: [
                      PageBannerStat(
                          icon: Icons.people,
                          value: '1,234',
                          label: 'Search appearances · 30 days'),
                    ]),
              ],
            )),
      )));
      await tester.pumpAndSettle();
      final copy = AppLocalizations(locale);
      await tester.tap(find.text(copy.translate('Dashboard')).first);
      await tester.tap(find.text(copy.translate('Applications')));
      final tooltip = copy.translate('Notifications, {0} unread', {'0': 123});
      await tester.tap(find.byTooltip(tooltip));
      expect([dashboards, applications, notifications], [1, 1, 1]);
      expect(find.bySemanticsLabel(tooltip), findsOneWidget);
      final feed =
          tester.getSemantics(find.bySemanticsLabel(copy.translate('Feed')));
      expect(feed.hasFlag(SemanticsFlag.isSelected), isTrue);
      expect(feed.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      await tester.tap(find.text(copy.translate('Chat')));
      expect(tabs.activeIndex, 2);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }
}

class _TestTabsRouter implements TabsRouter {
  @override
  int activeIndex = 0;
  @override
  void setActiveIndex(int index, {bool notify = true}) => activeIndex = index;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
