import 'dart:convert';
import 'api_exception.dart';

/// The gateway wraps model text in SSE chunk/done/error records. Decode the
/// envelope before parsing model JSON, and never accept a truncated response.
Stream<String> aiTextChunks(Stream<List<int>> bytes) async* {
  var complete = false;
  final data = <String>[];
  await for (final line
      in bytes.transform(utf8.decoder).transform(const LineSplitter())) {
    if (line.startsWith(':')) continue;
    if (line.startsWith('data:')) {
      data.add(line.substring(5).trimLeft());
      continue;
    }
    if (line.isNotEmpty || data.isEmpty) continue;
    final dynamic event;
    try {
      event = jsonDecode(data.join('\n'));
    } catch (_) {
      throw ApiException(message: 'The AI response could not be read.');
    }
    data.clear();
    if (event is! Map) {
      throw ApiException(message: 'The AI response could not be read.');
    }
    switch (event['t']) {
      case 'chunk':
        if (event['v'] is! String) {
          throw ApiException(message: 'The AI response could not be read.');
        }
        yield event['v'] as String;
      case 'done':
        complete = true;
        return;
      case 'error':
        throw ApiException(
            message:
                'AI writing did not finish. Your draft is unchanged; please try again.');
      default:
        throw ApiException(message: 'The AI response could not be read.');
    }
  }
  if (!complete) {
    throw ApiException(
        message:
            'AI writing did not finish. Your draft is unchanged; please try again.');
  }
}

Stream<Map<String, dynamic>> aiJsonRecords(Stream<List<int>> bytes) async* {
  await for (final line
      in aiTextChunks(bytes).transform(const LineSplitter())) {
    if (line.trim().isEmpty) continue;
    try {
      final record = jsonDecode(line);
      if (record is! Map) throw const FormatException();
      yield Map<String, dynamic>.from(record);
    } catch (_) {
      throw ApiException(message: 'The AI response could not be read.');
    }
  }
}
