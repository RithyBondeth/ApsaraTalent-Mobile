import 'package:apsaratalent_mobile/core/network/ai_stream.dart';
import 'package:dio/dio.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';

class AiQuota {
  const AiQuota(
      {required this.remaining,
      required this.limit,
      required this.cvRemaining,
      required this.cvLimit,
      required this.resetsAt});
  final int remaining, limit, cvRemaining, cvLimit;
  final DateTime resetsAt;
  factory AiQuota.fromJson(dynamic value) {
    try {
      final daily = value['daily'];
      final cv = value['actions']['cvGeneration'];
      final quota = AiQuota(
          remaining: daily['remaining'] as int,
          limit: daily['limit'] as int,
          cvRemaining: cv['remaining'] as int,
          cvLimit: cv['limit'] as int,
          resetsAt: DateTime.parse(value['resetsAt'] as String));
      if (quota.remaining < 0 ||
          quota.cvRemaining < 0 ||
          quota.limit < 0 ||
          quota.cvLimit < 0 ||
          quota.remaining > quota.limit ||
          quota.cvRemaining > quota.cvLimit) {
        throw const FormatException();
      }
      return quota;
    } catch (_) {
      throw ApiException(
          message: 'AI usage could not be read. Please refresh.');
    }
  }
  bool exhausted({bool cvGeneration = false}) =>
      DateTime.now().isBefore(resetsAt) &&
      (remaining == 0 || (cvGeneration && cvRemaining == 0));
}

class AiRepository {
  AiRepository(this.client);
  final ApiClient client;
  Future<AiQuota> quota() async =>
      AiQuota.fromJson((await client.get('/ai/quota')).data);

  Future<T> run<T>(Future<T> Function() action,
      {bool cvGeneration = false}) async {
    final usage = await quota();
    if (usage.exhausted(cvGeneration: cvGeneration)) {
      throw ApiException(
          message: cvGeneration && usage.cvRemaining == 0
              ? 'Your daily CV generation allowance is used up. You can still edit and preview PDFs.'
              : 'Your daily AI allowance is used up. Try again after the reset shown below.');
    }
    return action();
  }

  Future<String> coverLetter(Map<String, dynamic> data) =>
      _text('/resume/cover-letter', data);
  Future<String> polish(String text) =>
      _text('/resume/polish-cover-letter', {'coverLetterText': text});
  Future<String> _text(String path, Map<String, dynamic> data) async {
    final result = (await client.post(path,
            data: data,
            options: Options(receiveTimeout: const Duration(minutes: 3))))
        .data;
    if (result is! Map ||
        result['coverLetter'] is! String ||
        (result['coverLetter'] as String).trim().isEmpty) {
      throw ApiException(
          message: 'No writing was returned. Your draft is unchanged.');
    }
    return (result['coverLetter'] as String).trim();
  }

  Future<String> refineBio(Map<String, dynamic> data) async {
    final response = await client.post('/resume/refine-bio/stream',
        data: data,
        options: Options(
            responseType: ResponseType.stream,
            receiveTimeout: const Duration(minutes: 3)));
    final body = response.data;
    if (body is! ResponseBody) {
      throw ApiException(message: 'The AI response could not be read.');
    }
    return readBioStream(body.stream.cast<List<int>>());
  }
}

/// Gateway SSE records can be split anywhere, including within UTF-8 text.
/// A partial stream is never committed as a completed draft.
Future<String> readBioStream(Stream<List<int>> stream) async {
  final text = StringBuffer();
  try {
    await for (final chunk in aiTextChunks(stream)) {
      text.write(chunk);
    }
    if (text.toString().trim().isEmpty) throw const FormatException();
    return text.toString().trim();
  } catch (_) {
    throw ApiException(
        message:
            'AI writing did not finish. Your draft is unchanged; please try again.');
  }
}
