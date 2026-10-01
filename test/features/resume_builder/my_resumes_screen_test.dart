import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/resume_builder/data/resume_repository.dart';
import 'package:apsaratalent_mobile/features/resume_builder/presentation/screens/my_resumes_screen.dart';
import '../../support/fake_http.dart';

void main() {
  testWidgets('lists, renames, duplicates and confirms deletion',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final record = {
      'id': 'draft',
      'name': 'Engineer',
      'revision': 1,
      'updatedAt': '2026-09-30T00:00:00Z',
      'content': {
        'skills': [],
        'experience': [],
        'personalInfo': {},
        'template': 'modern'
      }
    };
    final http = FakeHttp((r) async => jsonResponse(200,
        r.method == 'GET' && r.path == '/resume/drafts' ? [record] : record));
    await tester.pumpWidget(MaterialApp(
        home: MyResumesScreen(
            repository: ResumeRepository(ApiClient(
                sessionStore: SessionStore(),
                baseUrl: 'http://api.test',
                adapter: http)))));
    await tester.pumpAndSettle();
    expect(find.text('Engineer'), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Senior engineer');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(http.requests.firstWhere((r) => r.method == 'PUT').data['name'],
        'Senior engineer');
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicate'));
    await tester.pumpAndSettle();
    expect(http.requests.firstWhere((r) => r.method == 'POST').data['name'],
        'Engineer (copy)');
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(http.requests.where((r) => r.method == 'DELETE'), isEmpty);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(http.requests.where((r) => r.method == 'DELETE'), hasLength(1));
    expect(tester.takeException(), isNull);
  });
}
