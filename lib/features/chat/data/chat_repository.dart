import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import '../domain/chat_models.dart';

class ChatRepository {
  ChatRepository(this.api);
  final ApiClient api;
  Future<List<Conversation>> recent() async {
    final response = await api.get('/chat/recent');
    if (response.data is! List) {
      throw ApiException(message: 'Could not read conversations.');
    }
    return (response.data as List).map(Conversation.fromJson).toList();
  }

  Future<Conversation> initiate(String id) async => Conversation.fromJson(
      (await api.post('/chat/initiate', data: {'receiverId': id})).data);

  static const mimeTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'txt': 'text/plain',
    'webm': 'audio/webm',
    'ogg': 'audio/ogg',
    'm4a': 'audio/mp4',
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
  };
  Future<ChatAttachment> upload(String filename, Uint8List bytes) async {
    final mime = mimeTypes[filename.split('.').last.toLowerCase()];
    if (mime == null) {
      throw ApiException(
          message: 'Choose an image, PDF, Word document, text or audio file.');
    }
    if (bytes.isEmpty || bytes.length > 10 * 1024 * 1024) {
      throw ApiException(
          message: 'Choose a non-empty file smaller than 10 MB.');
    }
    // Refresh before constructing FormData: consumed multipart bodies cannot
    // be replayed by the ordinary session interceptor.
    await api.get('/user/current-user');
    return ChatAttachment.fromJson((await api.post('/chat/upload',
            data: FormData.fromMap({
              'file': MultipartFile.fromBytes(bytes,
                  filename: filename, contentType: MediaType.parse(mime))
            }),
            options: Options(contentType: 'multipart/form-data')))
        .data);
  }

  /// Never send the bearer token to a URL supplied by a message. Legacy paths
  /// are mapped onto the authenticated gateway route, then strictly validated.
  static String attachmentPath(String value) {
    final uri = Uri.tryParse(value);
    var path = uri?.path ?? '';
    path = path.replaceFirst(RegExp(r'^/storage/chat/'), '/chat/attachment/');
    if (!RegExp(r'^/chat/attachment/\d{4}-\d{2}-\d{2}/[A-Za-z0-9_.-]+$')
        .hasMatch(path)) {
      throw ApiException(message: 'Invalid attachment link.');
    }
    return path;
  }

  Future<Uint8List> download(String url) async {
    final response = await api.get(attachmentPath(url),
        options: Options(responseType: ResponseType.bytes));
    return Uint8List.fromList(List<int>.from(response.data));
  }

  Future<List<Map<String, dynamic>>> iceServers() async {
    final data = chatMap((await api.get('/auth/ice-servers')).data);
    final servers = data['iceServers'];
    if (servers is! List || servers.isEmpty) {
      throw ApiException(
          message: 'Calling servers are unavailable. Try again later.');
    }
    return servers.map(chatMap).toList();
  }
}
