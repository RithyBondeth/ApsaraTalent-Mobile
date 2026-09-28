import 'dart:convert';

import 'package:apsaratalent_mobile/core/constants/apis/match_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/match/domain/entities/ai_match_tools.dart';
import 'package:dio/dio.dart';

class AiMatchToolsRepository {
  AiMatchToolsRepository(this._client);
  final ApiClient _client;

  Future<AiMatchExplanation> explanation(String eid, String cid,
      {String lang = 'en'}) async {
    final response = await _client
        .get(apiAiMatchExplanation(eid, cid), queryParameters: {'lang': lang});
    return AiMatchExplanation.fromJson(_object(response.data));
  }

  Future<List<InterviewQuestion>> interviewPrep(String eid, String cid,
      {String? interviewTitle}) async {
    final response =
        await _client.get(apiAiInterviewPrep(eid, cid), queryParameters: {
      if (interviewTitle != null && interviewTitle.trim().isNotEmpty)
        'interviewTitle': interviewTitle.trim(),
    });
    final rows = _object(response.data)['questions'];
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((row) => InterviewQuestion.fromJson(row.cast<String, dynamic>()))
        .toList();
  }

  Future<SkillGapAnalysis> skillGap(String eid, String cid,
      {String lang = 'en'}) async {
    final response = await _client.get(
      apiAiSkillGap(eid, cid),
      queryParameters: {'lang': lang},
      options: Options(responseType: ResponseType.stream),
    );
    final body = response.data;
    if (body is! ResponseBody) {
      throw ApiException(message: 'The skill-gap analysis could not be read.');
    }
    final matched = <String>[];
    final missing = <SkillGapItem>[];
    var overall = 'unknown';
    var weeks = 0;
    var priority = '';
    await for (final line in body.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      final text = line.trim();
      if (text.isEmpty) continue;
      final decoded = jsonDecode(text);
      if (decoded is! Map) continue;
      final row = decoded.cast<String, dynamic>();
      switch (row['t']) {
        case 'matched':
          final skill = '${row['skill'] ?? ''}'.trim();
          if (skill.isNotEmpty) matched.add(skill);
          break;
        case 'missing':
          missing.add(SkillGapItem.fromJson(row));
          break;
        case 'summary':
          overall = '${row['overallGap'] ?? 'unknown'}';
          weeks = (row['estimatedWeeks'] as num?)?.toInt() ?? 0;
          priority = '${row['topPriority'] ?? ''}';
          break;
      }
    }
    if (overall == 'unknown') {
      throw ApiException(
          message: 'The skill-gap analysis ended before its summary.');
    }
    return SkillGapAnalysis(
        matchedSkills: matched,
        missingSkills: missing,
        overallGap: overall,
        estimatedWeeks: weeks,
        topPriority: priority);
  }

  Map<String, dynamic> _object(dynamic data) {
    if (data is Map) return data.cast<String, dynamic>();
    throw ApiException(message: 'The AI response could not be read.');
  }
}
