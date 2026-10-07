import 'package:apsaratalent_mobile/core/network/generated/gateway_api.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Map<String, dynamic> resumeFromProfile(EmployeeProfile p, String email) => {
      'personalInfo': {
        'fullName': p.fullName,
        'email': email,
        'phone': p.phone ?? '',
        'location': p.location ?? '',
        'job': p.job ?? '',
        'socials': {
          for (final s in p.socials)
            if (s.platform != null && s.url != null) s.platform!: s.url
        },
      },
      'summary': p.description ?? '',
      'yearsOfExperience': p.yearsOfExperience ?? '',
      'availability': p.availability ?? '',
      'experience': [
        for (final e in p.experiences)
          {
            'company': e.company ?? '',
            'position': e.title ?? '',
            'startDate': e.startDate ?? '',
            'endDate': e.endDate ?? 'Present',
            'description': e.description ?? '',
            'achievements': <String>[],
          }
      ],
      'skills': [...p.skills],
      'education': p.educations
          .map((e) =>
              [e.degree, e.school, e.year].whereType<String>().join(', '))
          .join('\n'),
      'careerScopes': [...p.careerScopes],
      'template': 'modern',
    };

class ResumeRepository {
  ResumeRepository(this.client);
  final ApiClient client;
  Future<List<Map<String, dynamic>>> drafts() async =>
      ((await GatewayApi(client).resumeDraftControllerList()).data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

  Future<Map<String, dynamic>> draft(String id) async =>
      Map<String, dynamic>.from(
          (await GatewayApi(client).resumeDraftControllerRead(id: id)).data
              as Map);

  Future<Map<String, dynamic>> saveDraft(
      String name, Map<String, dynamic> content,
      {String? id, int? revision}) async {
    final api = GatewayApi(client);
    final response = revision == null
        ? await api.resumeDraftControllerCreate(
            body: ApiCreateResumeDraftDTO(
                name: name, content: content, id: id ?? const Uuid().v4()))
        : await api.resumeDraftControllerUpdate(
            id: id!,
            body: ApiUpdateResumeDraftDTO(
                name: name, content: content, revision: revision));
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deleteDraft(String id) async {
    await GatewayApi(client).resumeDraftControllerRemove(id: id);
  }

  Future<List<Map<String, dynamic>>> templates() async {
    final data = (await client.get('/resume/template/all')).data;
    if (data is! List) {
      throw ApiException(message: 'Could not read resume templates.');
    }
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> generate(Map<String, dynamic> draft) async {
    final data = (await GatewayApi(client)
            .resumeBuilderControllerGenerateResume(
                body: ApiBuildResumeDTO.fromJson(draft),
                options: Options(receiveTimeout: const Duration(minutes: 3))))
        .data;
    if (data is! Map ||
        data['experience'] is! List ||
        data['skills'] is! List) {
      throw ApiException(
          message:
              'The generated resume could not be read. Your draft is unchanged.');
    }
    return {
      ...draft,
      ...Map<String, dynamic>.from(data),
      'personalInfo': draft['personalInfo'],
      'template': draft['template'],
      if (draft.containsKey('design')) 'design': draft['design'],
      if (draft.containsKey('sectionOrder'))
        'sectionOrder': draft['sectionOrder'],
    };
  }

  Future<Map<String, dynamic>> generateFromText(
      String text, String template) async {
    final data = (await GatewayApi(client)
            .resumeBuilderControllerGenerateResumeFromText(
                body: ApiGenerateResumeFromTextDTO(
                    sourceText: text.trim(), template: template),
                options: Options(receiveTimeout: const Duration(minutes: 3))))
        .data;
    if (data is! Map ||
        data['personalInfo'] is! Map ||
        data['skills'] is! List ||
        data['experience'] is! List) {
      throw ApiException(
          message:
              'The generated resume could not be read. Your draft is unchanged.');
    }
    return {...Map<String, dynamic>.from(data), 'template': template};
  }

  Future<Map<String, dynamic>> optimize(Map<String, dynamic> draft) async {
    final data = (await GatewayApi(client)
            .resumeBuilderControllerOptimizeResume(
                body: ApiOptimizeResumeDTO.fromJson(draft),
                options: Options(receiveTimeout: const Duration(minutes: 3))))
        .data;
    if (data is! Map ||
        data['overallFeedback'] is! String ||
        data['suggestedSummary'] is! String ||
        data['suggestedSkills'] is! List ||
        data['experienceSuggestions'] is! List ||
        (data['suggestedSkills'] as List).any((v) => v is! String) ||
        (data['experienceSuggestions'] as List).any((v) =>
            v is! Map ||
            v['index'] is! int ||
            v['index'] < 0 ||
            v['index'] >= (draft['experience'] as List).length ||
            v['improvedDescription'] is! String ||
            v['improvedAchievements'] is! List ||
            (v['improvedAchievements'] as List).any((a) => a is! String))) {
      throw ApiException(
          message:
              'The suggestions could not be read. Your draft is unchanged.');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<Uint8List> coverLetterPdf(Map<String, dynamic> data) async => _pdf(
      (await GatewayApi(client).resumeBuilderControllerGenerateCoverLetterPdf(
              body: ApiGenerateCoverLetterPdfDTO.fromJson(data),
              options: Options(receiveTimeout: const Duration(minutes: 3))))
          .data);

  Future<Uint8List> build(Map<String, dynamic> draft) async {
    final data = (await GatewayApi(client).resumeBuilderControllerBuildResume(
            body: ApiBuildResumeDTO.fromJson(draft),
            options: Options(receiveTimeout: const Duration(minutes: 3))))
        .data;
    return _pdf(data);
  }

  Uint8List _pdf(dynamic data) {
    try {
      if (data is! Map || data['mimeType'] != 'application/pdf') {
        throw const FormatException();
      }
      final bytes = base64Decode(data['data'] as String);
      if (bytes.length < 5 || ascii.decode(bytes.take(5).toList()) != '%PDF-') {
        throw const FormatException();
      }
      return bytes;
    } catch (_) {
      throw ApiException(
          message: 'The server did not return a valid PDF. Please try again.');
    }
  }
}

class ResumeDraftStore {
  ResumeDraftStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  String _key(String profileId) => 'resume.draft.$profileId';

  Future<Map<String, dynamic>?> recovery(String profileId) async {
    final raw = await _storage.read(key: '${_key(profileId)}.sync');
    if (raw == null) return null;
    try {
      final value = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      if (value['content'] is! Map) return null;
      return value;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRecovery(String profileId, Map<String, dynamic> record) =>
      _storage.write(key: '${_key(profileId)}.sync', value: jsonEncode(record));

  Future<void> clearRecovery(String profileId) =>
      _storage.delete(key: '${_key(profileId)}.sync');

  Future<Map<String, dynamic>?> read(String profileId) async {
    final raw = await _storage.read(key: _key(profileId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map || decoded['draft'] is! Map) return null;
      final draft = decoded['draft'].cast<String, dynamic>();
      if (draft['personalInfo'] is! Map || draft['template'] is! String) {
        return null;
      }
      return draft;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String profileId, Map<String, dynamic> draft) async {
    await _storage.write(
        key: _key(profileId),
        value: jsonEncode({
          'version': 1,
          'savedAt': DateTime.now().toUtc().toIso8601String(),
          'draft': draft,
        }));
  }

  Future<void> clear(String profileId) => _storage.delete(key: _key(profileId));
}
