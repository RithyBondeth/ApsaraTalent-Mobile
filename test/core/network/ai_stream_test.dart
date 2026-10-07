import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:apsaratalent_mobile/core/network/ai_stream.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';

Stream<List<int>> bytes(String value) =>
    Stream.fromIterable(utf8.encode(value).map((b) => [b]));
String frame(Map<String, dynamic> event) =>
    'data: ${jsonEncode(event)}\r\n\r\n';
void main() {
  test('decodes Khmer and model JSON across every byte boundary', () async {
    final record = '${jsonEncode({'type': 'summary', 'value': 'ជំនាញ'})}\n';
    final stream = [
      ': heartbeat\r\n\r\n',
      frame({'t': 'chunk', 'v': record.substring(0, 12)}),
      frame({'t': 'chunk', 'v': record.substring(12)}),
      frame({'t': 'done'})
    ].join();
    expect(await aiJsonRecords(bytes(stream)).toList(), [
      {'type': 'summary', 'value': 'ជំនាញ'}
    ]);
  });
  test('requires completion and rejects server errors or malformed envelopes',
      () async {
    for (final stream in [
      frame({'t': 'chunk', 'v': 'partial'}),
      frame({'t': 'error'}),
      'data: invalid\n\n',
      frame({'t': 'chunk', 'v': 1})
    ]) {
      await expectLater(
          aiTextChunks(bytes(stream)).toList(), throwsA(isA<ApiException>()));
    }
  });
  test('reads a final NDJSON record without a trailing newline', () async {
    final stream =
        frame({'t': 'chunk', 'v': '{"type":"summary","value":"Complete"}'}) +
            frame({'t': 'done'});
    expect((await aiJsonRecords(bytes(stream)).single)['value'], 'Complete');
  });
}
