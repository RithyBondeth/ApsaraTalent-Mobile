import 'dart:convert';
import 'dart:typed_data';
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
  Future<List<Map<String, dynamic>>> templates() async {
    final data = (await client.get('/resume/template/all')).data;
    if (data is! List) {
      throw ApiException(message: 'Could not read resume templates.');
    }
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> generate(Map<String, dynamic> draft) async {
    final data = (await client.post('/resume/generate',
            data: draft,
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
      ...Map<String, dynamic>.from(data),
      'personalInfo': draft['personalInfo'],
      'template': draft['template']
    };
  }

  Future<Uint8List> build(Map<String, dynamic> draft) async {
    final data = (await client.post('/resume/build-resume',
            data: draft,
            options: Options(receiveTimeout: const Duration(minutes: 3))))
        .data;
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
