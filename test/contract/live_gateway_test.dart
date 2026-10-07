import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/core/session/auth_tokens.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/generated/gateway_api.dart';

void main() {
  final base = Platform.environment['E2E_API_URL'];
  test(
      'generated Dart client reads and updates the real gateway draft contract',
      () async {
    final uri = Uri.parse(base!);
    expect(uri.host, '127.0.0.1');
    expect(uri.port, 13000);
    FlutterSecureStorage.setMockInitialValues({});
    final store = SessionStore();
    await store.save(
        AuthTokens(
            accessToken: Platform.environment['E2E_ACCESS_TOKEN']!,
            refreshToken: 'isolated-test'),
        remember: false);
    final api = GatewayApi(ApiClient(sessionStore: store, baseUrl: base));
    final id = Platform.environment['E2E_DRAFT_ID']!;
    final response = await api.resumeDraftControllerRead(id: id);
    final draft = ApiResumeDraftRecordDTO.fromJson(
        Map<String, dynamic>.from(response.data as Map));
    expect(draft.id, id);
    expect(draft.content['summary'], 'Mobile edit');
    expect(draft.content['design']['customAccent'], '#3366CC');
    final saved = await api.resumeDraftControllerUpdate(
        id: id,
        body: ApiUpdateResumeDraftDTO(
            name: draft.name,
            revision: draft.revision,
            content: {
              ...draft.content,
              'summary': 'Dart generated client edit'
            }));
    final updated = ApiResumeDraftRecordDTO.fromJson(
        Map<String, dynamic>.from(saved.data as Map));
    expect(updated.revision, draft.revision + 1);
    expect(updated.content['sectionOrder'], draft.content['sectionOrder']);
  },
      skip: base == null
          ? 'Run with the isolated API e2e runner (E2E_CLIENTS=1).'
          : false);
}
