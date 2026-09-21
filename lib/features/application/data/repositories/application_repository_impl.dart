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
