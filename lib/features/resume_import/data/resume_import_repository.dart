import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/api_interceptors.dart';
import 'package:apsaratalent_mobile/features/auth/domain/constants/signup_options.dart';

const maxResumeImportBytes = 5 * 1024 * 1024;

/// The parser is AI-backed. Keep only fields understood by the profile API;
/// never allow imported account credentials or record IDs through.
Map<String, dynamic> normalizeResumeImport(Map data,
    {Set<String>? careerScopes}) {
  final result = <String, dynamic>{};
  const names = {
    'firstName': 'firstname',
    'lastName': 'lastname',
    'jobTitle': 'job',
    'description': 'description'
  };
  for (final entry in names.entries) {
    final value = data[entry.key];
    if (value is String && value.trim().isNotEmpty) {
      result[entry.value] = value.trim();
    }
  }
  for (final entry in {
    'location': SignupOptions.locations,
    'yearsOfExperience':
        SignupOptions.yearsOfExperience.map((o) => o.value).toList(),
    'availability': SignupOptions.availability.map((o) => o.value).toList(),
  }.entries) {
    if (entry.value.contains(data[entry.key])) {
      result[entry.key] = data[entry.key];
    }
  }
  for (final key in ['skills', 'careerScopes']) {
    final raw = data[key];
    if (raw is! List) continue;
    final values = raw
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) =>
            s.isNotEmpty &&
            (key != 'careerScopes' ||
                careerScopes == null ||
                careerScopes.contains(s)))
        .toSet()
        .toList();
    if (values.isNotEmpty) result[key] = values;
  }
  for (final key in ['experiences', 'educations']) {
    final raw = data[key];
    if (raw is! List) continue;
    final rows = <Map<String, dynamic>>[];
    for (final row in raw.whereType<Map>()) {
      final clean = <String, dynamic>{};
      for (final field in key == 'experiences'
          ? ['title', 'company', 'description']
          : ['school', 'degree']) {
        if (row[field] is String && (row[field] as String).trim().isNotEmpty) {
          clean[field] = (row[field] as String).trim();
        }
      }
      if (key == 'experiences') {
        for (final field in ['startDate', 'endDate']) {
          final value = row[field];
          if (value is String &&
              RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
            final parsed = DateTime.tryParse(value);
            if (parsed != null && parsed.toIso8601String().startsWith(value)) {
              clean[field] = value;
            }
          }
        }
        if (!clean.containsKey('title')) continue;
      } else {
        final year = '${row['year'] ?? ''}';
        if (RegExp(r'^\d{4}$').hasMatch(year)) clean['year'] = year;
        if (!clean.containsKey('school') && !clean.containsKey('degree')) {
          continue;
        }
      }
      rows.add(clean);
    }
    if (rows.isNotEmpty) result[key] = rows;
  }
  return result;
}

class ResumeImportRepository {
  ResumeImportRepository(this.client);
  final ApiClient client;

  Future<Map<String, dynamic>> parse(String filename, Uint8List bytes,
      {Set<String>? careerScopes}) async {
    if (!filename.toLowerCase().endsWith('.pdf') ||
        bytes.length < 5 ||
        String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw ApiException(message: 'Choose a PDF resume.');
    }
    if (bytes.length > maxResumeImportBytes) {
      throw ApiException(message: 'Choose a PDF smaller than 5 MB.');
    }
    final response = await client.post('/auth/parse-resume',
        data: FormData.fromMap({
          'resume': MultipartFile.fromBytes(bytes,
              filename: filename, contentType: MediaType('application', 'pdf'))
        }),
        options: Options(
            contentType: 'multipart/form-data',
            extra: SessionInterceptor.publicRequest,
            receiveTimeout: const Duration(minutes: 3)));
    final data = response.data;
    if (data is! Map) {
      throw ApiException(
          message: 'The resume response could not be read. Please try again.');
    }
    final parsed = normalizeResumeImport(data, careerScopes: careerScopes);
    if (parsed.isEmpty) {
      throw ApiException(
          message:
              'No profile details could be extracted. Try a text-based PDF or enter your details manually.');
    }
    return parsed;
  }
}

/// Signup requires complete work history; profile edits accept partial entries.
List<Map<String, dynamic>> signupResumeExperiences(dynamic rows) => rows is List
    ? rows
        .whereType<Map>()
        .where((row) => ['title', 'description', 'startDate', 'endDate'].every(
            (key) =>
                row[key] is String && (row[key] as String).trim().isNotEmpty))
        .map((row) => Map<String, dynamic>.from(row))
        .toList()
    : [];
