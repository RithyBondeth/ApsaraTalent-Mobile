import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:flutter_test/flutter_test.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/core/session/auth_tokens.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_state.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:apsaratalent_mobile/features/feed/providers/feed_notifier.dart';
import 'package:apsaratalent_mobile/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:apsaratalent_mobile/features/resume_builder/data/resume_repository.dart';
import 'package:apsaratalent_mobile/features/resume_builder/presentation/screens/resume_builder_screen.dart';
import '../../support/fake_http.dart';

// Only external boundaries are fake. Import normalization/review, profile
// collections, repositories, session refresh, persistence and editor are real.
final _pdf =
    Uint8List.fromList(utf8.encode('%PDF-1.4\n% resume fixture\n%%EOF'));

final class _PickedPdf extends PlatformFile {
  @override
  String get name => 'candidate.pdf';
  @override
  Uri get uri => Uri.parse('file:///candidate.pdf');
  @override
  int lengthSync() => _pdf.length;
  @override
  Future<int> length() async => _pdf.length;
  @override
  Future<Uint8List> readAsBytes() async => _pdf;
  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(_pdf);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Picker extends FilePickerPlatform {
  @override
  Future<PlatformFile?> pickFile(
      {String? dialogTitle,
      String? initialDirectory,
      FileType type = FileType.any,
      List<String>? allowedExtensions,
      Function(FilePickerStatus)? onFileLoading,
      int compressionQuality = 0,
      AndroidOptions androidOptions = const AndroidOptions(),
      DarwinOptions darwinOptions = const DarwinOptions(),
      WindowsOptions windowsOptions = const WindowsOptions(),
      LinuxOptions linuxOptions = const LinuxOptions(),
      WebOptions webOptions = const WebOptions()}) async {
    expect(type, FileType.custom);
    expect(allowedExtensions, ['pdf']);
    return _PickedPdf();
  }
}

class _Session extends AuthSessionNotifier {
  @override
  Future<AuthSessionState> build() async =>
      const AuthSessionState.signedIn(null);
}

class _Server {
  Map<String, dynamic> profile = {
    'id': 'employee',
    'firstname': 'Original',
    'lastname': 'Candidate',
    'email': 'candidate@example.com',
    'skills': [],
    'experiences': [],
    'educations': []
  };
  final drafts = <String, Map<String, dynamic>>{};
  String validToken = 'initial';
  bool rejectRefresh = false;
  bool quotaRace = false;
  bool exhausted = false;
  bool invalidPdf = false;
  final requests = <Map<String, dynamic>>[];
  late final http = FakeHttp(handle);

  Future<ResponseBody> handle(RequestOptions r) async {
    // Snapshot because Dio mutates RequestOptions when replaying after refresh.
    requests.add({
      'path': r.path,
      'method': r.method,
      'auth': r.headers['Authorization'],
      'data': r.data is Map ? jsonDecode(jsonEncode(r.data)) : null
    });
    if (r.path == '/auth/parse-resume') {
      expect(r.headers['Authorization'], isNull);
      expect((r.data as FormData).files.single.key, 'resume');
      return jsonResponse(200, {
        'firstName': 'Imported',
        'lastName': 'Candidate',
        'description': 'Imported summary',
        'jobTitle': 'Engineer',
        'skills': ['Flutter'],
        'careerScopes': ['Software'],
        'experiences': [
          {
            'title': 'Developer',
            'company': 'Example Co',
            'startDate': '2022-01-01',
            'description': 'Built apps'
          }
        ],
        'educations': [
          {'school': 'Example University', 'degree': 'BSc', 'year': '2021'}
        ]
      });
    }
    if (r.path == '/auth/refresh') {
      if (rejectRefresh) {
        return jsonResponse(401, {'message': 'Refresh expired'});
      }
      validToken = 'refreshed';
      return jsonResponse(200, {'message': 'ok'},
          setCookies: authCookies(validToken, 'refresh-2'));
    }
    if (r.headers['Authorization'] != 'Bearer $validToken') {
      return jsonResponse(401, {'message': 'Session expired'});
    }
    if (r.path == '/public/user/career-scopes') {
      return jsonResponse(200, [
        {'name': 'Software'}
      ]);
    }
    if (r.path == '/user/employee/one/employee') {
      return jsonResponse(200, profile);
    }
    if (r.path == '/user/employee/update-info/employee') {
      expect(r.method, 'PATCH');
      profile = {...profile, ...Map<String, dynamic>.from(r.data as Map)};
      return jsonResponse(200, {'employee': profile});
    }
    if (r.path == '/resume/template/all') {
      return jsonResponse(200, [
        {'templateKey': 'modern', 'title': 'Modern'}
      ]);
    }
    if (r.path == '/ai/quota') {
      return jsonResponse(200, {
        'daily': {'remaining': exhausted ? 0 : 10, 'limit': 100},
        'actions': {
          'cvGeneration': {'remaining': exhausted ? 0 : 3, 'limit': 3}
        },
        'resetsAt':
            DateTime.now().add(const Duration(days: 1)).toIso8601String()
      });
    }
    if (r.path == '/resume/generate') {
      if (quotaRace) {
        exhausted = true;
        return jsonResponse(
            429, {'message': 'Daily CV generation limit reached'});
      }
      return jsonResponse(200, {...r.data as Map, 'summary': 'AI summary'});
    }
    if (r.path == '/resume/drafts') {
      if (r.method == 'GET') return jsonResponse(200, drafts.values.toList());
      expect(r.method, 'POST');
      final body = Map<String, dynamic>.from(r.data as Map);
      final id = body['id'] as String;
      drafts.putIfAbsent(id,
          () => {...body, 'revision': 1, 'updatedAt': '2026-09-30T00:00:00Z'});
      return jsonResponse(201, drafts[id]!);
    }
    if (r.path.startsWith('/resume/drafts/')) {
      final id = r.path.split('/').last;
      final record = drafts[id];
      if (record == null) return jsonResponse(404, {'message': 'Not found'});
      if (r.method == 'PUT') {
        expect(r.data['revision'], record['revision']);
        drafts[id] = {
          ...record,
          ...r.data as Map<String, dynamic>,
          'revision': (record['revision'] as int) + 1
        };
      } else {
        expect(r.method, 'GET');
      }
      return jsonResponse(200, drafts[id]!);
    }
    if (r.path == '/resume/build-resume') {
      return jsonResponse(200, {
        'mimeType': 'application/pdf',
        'data': base64Encode(invalidPdf ? utf8.encode('not a pdf') : _pdf)
      });
    }
    fail('Unexpected request: ${r.method} ${r.path}');
  }
}

class _Journey {
  final server = _Server();
  SessionStore store = SessionStore();
  final opened = <Uint8List>[];
  bool openingFails = false;

  Future<void> start(WidgetTester tester) async {
    await store.save(
        const AuthTokens(accessToken: 'initial', refreshToken: 'refresh-1'),
        remember: true);
    await mount(tester);
  }

  Future<void> mount(WidgetTester tester) async {
    final router = RootStackRouter.build(routes: [
      NamedRouteDef(
          name: 'Home',
          path: '/',
          builder: (context, _) => Scaffold(
                  body: Column(children: [
                TextButton(
                    onPressed: () => context.router.pushPath('/profile'),
                    child: const Text('Edit profile')),
                TextButton(
                    onPressed: () => context.router.pushPath('/resume'),
                    child: const Text('Resume builder'))
              ]))),
      NamedRouteDef(
          name: 'Profile',
          path: '/profile',
          builder: (_, __) => const ProfileEditScreen()),
      NamedRouteDef(
          name: 'Resume',
          path: '/resume',
          builder: (_, __) => const ResumeBuilderScreen()),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(ApiClient(
              sessionStore: store,
              baseUrl: 'http://api.test',
              adapter: server.http)),
          authSessionProvider.overrideWith(_Session.new),
          feedViewerProvider.overrideWithValue(const FeedViewer(
              role: FeedViewerRole.employee, profileId: 'employee')),
          resumePdfPreviewProvider.overrideWithValue((bytes) async {
            if (openingFails) {
              throw ApiException(
                  message:
                      'PDF created, but it could not be opened: No PDF viewer');
            }
            opened.add(Uint8List.fromList(bytes));
          }),
        ],
        child: MaterialApp.router(
            theme: AppTheme.light(), routerConfig: router.config())));
    await tester.pumpAndSettle();
  }

  Future<void> import(WidgetTester tester) async {
    await tap(tester, 'Edit profile');
    await tap(tester, 'Import resume');
    expect(find.text('Review resume details'), findsOneWidget);
    // Import review must not persist until the profile form is submitted.
    expect(server.requests.where((r) => r['method'] == 'PATCH'), isEmpty);
    await tap(tester, 'Apply selected');
    await tap(tester, 'Save changes');
    expect(server.profile['firstname'], 'Imported');
    expect(server.profile['skills'], contains(equals({'name': 'Flutter'})));
    await tap(tester, 'Resume builder');
    expect(find.text('Imported Candidate'), findsOneWidget);
  }

  Future<void> edit(WidgetTester tester, String summary) async {
    await tap(tester, 'Summary');
    await tester.enterText(find.byType(TextField), summary);
    await tap(tester, 'Save');
  }

  Future<void> reopen(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    store = SessionStore();
    await store.restore();
    await mount(tester);
    await tap(tester, 'Resume builder');
    await tap(tester, 'My resumes');
    await tap(tester, 'My resume');
  }
}

Future<void> tap(WidgetTester tester, String text) async {
  final target = find.text(text).last;
  await tester.ensureVisible(target);
  await tester.tap(target);
  if (text == 'Import resume') {
    // The import button stays busy while its review dialog is open.
    for (var i = 0;
        i < 50 && find.text('Review resume details').evaluate().isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pump(const Duration(milliseconds: 400));
    return;
  }
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    final picker = FilePickerPlatform.instance;
    FilePickerPlatform.instance = _Picker();
    addTearDown(() => FilePickerPlatform.instance = picker);
  });

  testWidgets(
      'import → review → profile save → edit → account save → reopen → PDF',
      (tester) async {
    final flow = _Journey();
    await flow.start(tester);
    await flow.import(tester);
    await flow.edit(tester, 'Edited after import');
    expect(find.text('Saved to your account'), findsOneWidget);
    expect(await ResumeDraftStore().recovery('employee'), isNull);
    await flow.reopen(tester);
    expect(find.text('Edited after import'), findsOneWidget);
    await tap(tester, 'Preview PDF');
    final payload = flow.server.requests
        .lastWhere((r) => r['path'] == '/resume/build-resume')['data'];
    expect(payload['summary'], 'Edited after import');
    expect(payload['personalInfo']['fullName'], 'Imported Candidate');
    expect(payload['skills'], ['Flutter']);
    expect(payload['experience'].single['company'], 'Example Co');
    expect(payload['education'], 'BSc, Example University, 2021');
    expect(flow.opened.single, _pdf);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'expired sessions refresh during saving and exporting without duplicate drafts',
      (tester) async {
    final flow = _Journey();
    await flow.start(tester);
    await flow.import(tester);
    flow.server.validToken = 'expired-on-server';
    await flow.edit(tester, 'Survives token rotation');
    expect(flow.server.drafts, hasLength(1));
    final saves = flow.server.requests
        .where((r) => r['path'] == '/resume/drafts' && r['method'] == 'POST')
        .toList();
    expect(saves, hasLength(2));
    expect(saves.first['data'], saves.last['data']);
    expect(saves.last['auth'], 'Bearer refreshed');
    await flow.reopen(tester);
    flow.server.validToken = 'expired-again';
    await tap(tester, 'Preview PDF');
    expect(flow.server.requests.where((r) => r['path'] == '/auth/refresh'),
        hasLength(2));
    expect(
        flow.server.requests.where((r) => r['path'] == '/resume/build-resume'),
        hasLength(2));
    expect(flow.opened, hasLength(1));
    expect(flow.server.drafts.values.single['content']['summary'],
        'Survives token rotation');
  });

  testWidgets(
      'rejected refresh preserves edits for recovery after signing in again',
      (tester) async {
    final flow = _Journey();
    await flow.start(tester);
    await flow.import(tester);
    flow.server.validToken = 'expired';
    flow.server.rejectRefresh = true;
    await flow.edit(tester, 'Recover after sign-in');
    expect(flow.store.hasSession, isFalse);
    expect(flow.server.drafts, isEmpty);
    final recovery = await ResumeDraftStore().recovery('employee');
    expect(recovery!['content']['summary'], 'Recover after sign-in');
    expect(flow.server.requests.where((r) => r['path'] == '/auth/refresh'),
        hasLength(1));
    // Simulate a successful sign-in; the login UI is outside this flow.
    flow.server.validToken = 'initial';
    flow.server.rejectRefresh = false;
    await flow.store.save(
        const AuthTokens(accessToken: 'initial', refreshToken: 'refresh-1'),
        remember: true);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await flow.mount(tester);
    await tap(tester, 'Resume builder');
    expect(find.text('Recover after sign-in'), findsOneWidget);
    await tap(tester, 'Retry save');
    expect(flow.server.drafts.keys.single, recovery['id']);
    await flow.reopen(tester);
    await tap(tester, 'Preview PDF');
    expect(flow.opened.single, _pdf);
  });

  testWidgets(
      'quota race preserves saved edits and still permits reopen and export',
      (tester) async {
    final flow = _Journey();
    await flow.start(tester);
    await flow.import(tester);
    await flow.edit(tester, 'Keep my own summary');
    flow.server.quotaRace = true;
    await tap(tester, 'Generate AI draft');
    expect(find.text('Daily CV generation limit reached'), findsOneWidget);
    expect(flow.server.drafts.values.single['content']['summary'],
        'Keep my own summary');
    await flow.reopen(tester);
    await tap(tester, 'Generate AI draft');
    expect(flow.server.requests.where((r) => r['path'] == '/resume/generate'),
        hasLength(1));
    await tap(tester, 'Preview PDF');
    expect(flow.opened.single, _pdf);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'invalid PDF and native opening failure preserve the saved resume for retry',
      (tester) async {
    final flow = _Journey();
    await flow.start(tester);
    await flow.import(tester);
    await flow.edit(tester, 'Still saved');
    await flow.reopen(tester);
    flow.server.invalidPdf = true;
    await tap(tester, 'Preview PDF');
    expect(
        find.text('The server did not return a valid PDF. Please try again.'),
        findsOneWidget);
    expect(flow.opened, isEmpty);
    flow.server.invalidPdf = false;
    flow.openingFails = true;
    await tap(tester, 'Preview PDF');
    expect(find.text('PDF created, but it could not be opened: No PDF viewer'),
        findsOneWidget);
    flow.openingFails = false;
    await tap(tester, 'Preview PDF');
    expect(flow.opened.single, _pdf);
    expect(
        flow.server.drafts.values.single['content']['summary'], 'Still saved');
    expect(tester.takeException(), isNull);
  });
}
