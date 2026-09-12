import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A Dio adapter that answers from a handler instead of the network, and
/// records every request it was asked to make.
class FakeHttp implements HttpClientAdapter {
  FakeHttp(this.handler);

  final Future<ResponseBody> Function(RequestOptions request) handler;
  final List<RequestOptions> requests = [];

  Iterable<RequestOptions> to(String path) =>
      requests.where((r) => r.path == path);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(
  int status,
  Object body, {
  List<String> setCookies = const [],
}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      if (setCookies.isNotEmpty) 'set-cookie': setCookies,
    },
  );
}

/// The cookie pair the gateway sets on sign-in and refresh.
List<String> authCookies(String access, String refresh) => [
      'auth-token=$access; Max-Age=86400; Path=/; HttpOnly; SameSite=Lax',
      'refresh-token=$refresh; Max-Age=2592000; Path=/; HttpOnly; SameSite=Lax',
    ];
