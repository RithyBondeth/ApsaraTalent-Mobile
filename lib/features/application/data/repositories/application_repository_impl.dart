import 'package:apsaratalent_mobile/core/constants/apis/application_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/job_application.dart';
import 'package:apsaratalent_mobile/features/application/domain/repositories/application_repository.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  ApplicationRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<JobApplication>> fetchMine() =>
      _guard('Could not load your applications.', () async {
        final response = await _client.get(apiMyApplications);
        final data = response.data;
        if (data is! List) return const <JobApplication>[];
        return data
            .whereType<Map>()
            .map((m) => JobApplication.fromJson(m.cast<String, dynamic>()))
            .toList();
      });

  @override
  Future<JobApplication> apply(String jobId, {String? coverLetterNote}) =>
      _guard('Could not send your application.', () async {
        final note = coverLetterNote?.trim();
        final response = await _client.post(apiApplyToJob, data: {
          'jobId': jobId,
          // Omitted rather than sent empty: the API stores null for "no note",
          // and an empty string would overwrite a note a revived application
          // already had.
          if (note != null && note.isNotEmpty) 'coverLetterNote': note,
        });
        final data = response.data;
        if (data is! Map) {
          throw ApiException(message: 'Could not read that application.');
        }
        return JobApplication.fromJson(data.cast<String, dynamic>());
      });

  @override
  Future<void> withdraw(String applicationId) =>
      _guard('Could not withdraw that application.', () async {
        await _client.delete(apiWithdrawApplication(applicationId));
      });

  Future<T> _guard<T>(String fallback, Future<T> Function() body) async {
    try {
      return await body();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: fallback);
    }
  }
}
