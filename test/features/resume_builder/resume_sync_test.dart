import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/features/resume_builder/data/resume_repository.dart';
import '../../support/fake_http.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  ResumeRepository repo(FakeHttp http) => ResumeRepository(ApiClient(
      sessionStore: SessionStore(), baseUrl: 'http://api.test', adapter: http));
  test('creates, lists, reopens, updates and deletes account resumes',
      () async {
    final content = {
      'personalInfo': {'fullName': 'Candidate'},
      'skills': [],
      'experience': [],
      'template': 'modern'
    };
    final record = {
      'id': 'draft-id',
      'name': 'Engineer',
      'content': content,
      'revision': 1
    };
    final http = FakeHttp((r) async => jsonResponse(200,
        r.method == 'GET' && r.path == '/resume/drafts' ? [record] : record));
    final repository = repo(http);
    await repository.saveDraft('Engineer', content, id: 'draft-id');
    expect(http.requests.last.method, 'POST');
    expect(http.requests.last.data,
        {'id': 'draft-id', 'name': 'Engineer', 'content': content});
    expect((await repository.drafts()).single['name'], 'Engineer');
    expect((await repository.draft('draft-id'))['content'], content);
    await repository.saveDraft('Engineer 2', content,
        id: 'draft-id', revision: 1);
    expect(http.requests.last.method, 'PUT');
    expect(http.requests.last.data['revision'], 1);
    await repository.deleteDraft('draft-id');
    expect(http.requests.last.method, 'DELETE');
  });
  test('conflicts retain the revision and recovery copy across store instances',
      () async {
    final record = {
      'id': 'draft-id',
      'name': 'Resume',
      'revision': 3,
      'content': {'summary': 'My changes'}
    };
    await ResumeDraftStore().saveRecovery('account-a', record);
    final http = FakeHttp((_) async =>
        jsonResponse(409, {'message': 'Changed on another device'}));
    await expectLater(
        repo(http).saveDraft('Resume', {'summary': 'My changes'},
            id: 'draft-id', revision: 3),
        throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'status', 409)));
    expect(await ResumeDraftStore().recovery('account-a'), record);
    expect(await ResumeDraftStore().recovery('account-b'), isNull);
    await ResumeDraftStore().clearRecovery('account-a');
    expect(await ResumeDraftStore().recovery('account-a'), isNull);
  });
}
