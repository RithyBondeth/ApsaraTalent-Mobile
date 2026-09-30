import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';

typedef PdfFileOpener = Future<OpenResult> Function(String path);

Future<void> saveAndOpenInterviewPdf(
  Uint8List bytes,
  Directory directory, {
  PdfFileOpener opener = OpenFilex.open,
  String filename = 'interview-prep.pdf',
}) async {
  if (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
    throw ApiException(message: 'The interview prep PDF was invalid.');
  }
  final file = File('${directory.path}/$filename');
  try {
    await file.writeAsBytes(bytes, flush: true);
    final result = await opener(file.path);
    if (result.type != ResultType.done) {
      throw ApiException(
          message:
              'PDF created, but it could not be opened: ${result.message}');
    }
  } catch (error) {
    if (error is ApiException) rethrow;
    throw ApiException(message: 'PDF created, but it could not be opened.');
  }
}
