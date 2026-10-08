import 'dart:async';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_state.dart';
import 'package:apsaratalent_mobile/features/setting/presentation/screens/unsubscribe_screen.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/routes/auth_guard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/fake_http.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test('public links parse the same job ID and email token as web', () {
    final router = AppRouter(
        authGuard: AuthGuard(() => const AsyncLoading<AuthSessionState>()));
    final job = router.matcher.match('/jobs/job-123')!.single;
    expect(job.name, JobDetailRoute.name);
    expect(job.params.getString('jobId'), 'job-123');
    expect(job.guards, isEmpty);
    final unsubscribe =
        router.matcher.match('/unsubscribe?token=signed%2Btoken')!.single;
    expect(unsubscribe.name, UnsubscribeRoute.name);
    expect(unsubscribe.queryParams.getString('token'), 'signed+token');
    expect(unsubscribe.guards, isEmpty);
    expect(router.matcher.match('/admin')!.single.guards, hasLength(1));
    router.dispose();
  });
  Future<void> mount(WidgetTester tester, FakeHttp http, String token) async {
    await tester.pumpWidget(ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(ApiClient(
              sessionStore: SessionStore(),
              baseUrl: 'http://api.test',
              adapter: http)),
        ],
        child: MaterialApp(
            theme: AppTheme.light(), home: UnsubscribeScreen(token: token))));
    await tester.pumpAndSettle();
  }

  testWidgets('opening an email link does not unsubscribe until confirmed',
      (tester) async {
    final response = Completer<ResponseBody>();
    final http = FakeHttp((_) => response.future);
    await mount(tester, http, 'signed-token');
    expect(http.requests, isEmpty);
    await tester.runAsync(() async {
      await tester.tap(find.text('Unsubscribe'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
    expect(http.requests, hasLength(1));
    expect(http.requests.single.path, '/notification/preferences/unsubscribe');
    expect(http.requests.single.data, {'token': 'signed-token'});
    response
        .complete(jsonResponse(200, {'message': 'Unsubscribed successfully'}));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(find.text('You have unsubscribed.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('missing tokens cannot call the unsubscribe API', (tester) async {
    final http = FakeHttp((_) async => jsonResponse(200, {}));
    await mount(tester, http, '');
    expect(find.text('This unsubscribe link is invalid.'), findsOneWidget);
    expect(find.text('Unsubscribe'), findsNothing);
    expect(http.requests, isEmpty);
  });
}
