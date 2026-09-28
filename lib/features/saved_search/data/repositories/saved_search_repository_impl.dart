import 'package:apsaratalent_mobile/core/constants/apis/saved_search_api_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/saved_search/domain/entities/saved_search.dart';
import 'package:apsaratalent_mobile/features/saved_search/domain/repositories/saved_search_repository.dart';

class SavedSearchRepositoryImpl implements SavedSearchRepository {
  SavedSearchRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<SavedSearch>> fetchAll() =>
      _guard('Could not load your saved searches.', () async {
        final response = await _client.get(apiSavedSearches);
        final data = response.data;
        if (data is! List) return const <SavedSearch>[];
        return data
            .whereType<Map>()
            .map((m) => SavedSearch.fromJson(m.cast<String, dynamic>()))
            .toList();
      });

  @override
  Future<SavedSearch> create({
    required String name,
    required String keyword,
    List<String> careerScopes = const [],
    SearchFrequency frequency = SearchFrequency.weekly,
  }) =>
      _guard('Could not save that search.', () async {
        final response = await _client.post(apiSavedSearches, data: {
          'name': name.trim(),
          // The same shape the search screen sends as query parameters. This is
          // a JSON body, so the list-format trap on search does not apply.
          'filters': {
            'keyword': keyword.trim(),
            if (careerScopes.isNotEmpty) 'careerScopes': careerScopes,
          },
          'frequency': frequency.name,
        });
        return _one(response.data);
      });

  @override
  Future<SavedSearch> setFrequency(String id, SearchFrequency frequency) =>
      _guard('Could not change how often you hear about it.', () async {
        final response = await _client.patch(
          apiSavedSearch(id),
          data: {'frequency': frequency.name},
        );
        return _one(response.data);
      });

  @override
  Future<void> remove(String id) =>
      _guard('Could not delete that search.', () async {
        await _client.delete(apiSavedSearch(id));
      });

  @override
  Future<SavedSearchPreview> preview(String id) =>
      _guard('Could not count matches.', () async {
        final response = await _client.get(apiSavedSearchPreview(id));
        final data = response.data;
        if (data is! Map) {
          throw ApiException(message: 'Could not read that preview.');
        }
        return SavedSearchPreview.fromJson(data.cast<String, dynamic>());
      });

  SavedSearch _one(dynamic data) {
    if (data is! Map) {
      throw ApiException(message: 'Could not read that saved search.');
    }
    return SavedSearch.fromJson(data.cast<String, dynamic>());
  }

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
