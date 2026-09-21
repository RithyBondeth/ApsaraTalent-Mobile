import 'package:dio/dio.dart';

import 'package:apsaratalent_mobile/core/constants/apis/search_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/search/domain/entities/job_posting.dart';
import 'package:apsaratalent_mobile/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._client);

  final ApiClient _client;

  static const pageSize = 20;

  @override
  Future<SearchResults<JobPosting>> searchJobs({
    required String keyword,
    List<String> careerScopes = const [],
    int page = 1,
  }) =>
      _search(apiJobSearch, keyword, careerScopes, page, JobPosting.fromJson);

  @override
  Future<SearchResults<FeedEmployee>> searchTalent({
    required String keyword,
    List<String> careerScopes = const [],
    int page = 1,
  }) =>
      _search(
        apiEmployeeSearch,
        keyword,
        careerScopes,
        page,
        FeedEmployee.fromJson,
      );

  Future<SearchResults<T>> _search<T>(
    String path,
    String keyword,
    List<String> careerScopes,
    int page,
    T Function(Map<String, dynamic>) parse,
  ) =>
      _guard('Could not run that search.', () async {
        final response = await _client.get(
          path,
          // Dio's default list format is `careerScopes[]=a&careerScopes[]=b`,
          // which this API does not parse — the filter is dropped and every
          // posting comes back as if no scope had been asked for. It wants
          // `careerScopes=a&careerScopes=b`.
          options: Options(listFormat: ListFormat.multi),
          queryParameters: {
            // `keyword`, not `q`. A `q` is accepted and ignored, which
            // returns every posting — a search that looks like it works and
            // filters nothing.
            'keyword': keyword,
            'page': page,
            'pageSize': pageSize,
            // Scope names, and only when narrowing was asked for: an empty
            // list leaves the filter off entirely, which also keeps the API's
            // scope fallback from firing on a search nobody asked to narrow.
            if (careerScopes.isNotEmpty) 'careerScopes': careerScopes,
          },
        );
        final data = response.data;
        if (data is! Map) return SearchResults.empty<T>();
        return SearchResults.of(data.cast<String, dynamic>(), parse);
      });

  @override
  Future<JobPosting> fetchJob(String jobId) =>
      _guard('Could not load that job.', () async {
        final response = await _client.get(apiPublicJob(jobId));
        final data = response.data;
        if (data is! Map) {
          throw ApiException(message: 'Could not read that job.');
        }
        return JobPosting.fromJson(data.cast<String, dynamic>());
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
