import 'package:apsaratalent_mobile/features/saved_search/domain/entities/saved_search.dart';

abstract class SavedSearchRepository {
  Future<List<SavedSearch>> fetchAll();

  Future<SavedSearch> create({
    required String name,
    required String keyword,
    List<String> careerScopes,
    SearchFrequency frequency,
  });

  Future<SavedSearch> setFrequency(String id, SearchFrequency frequency);

  Future<void> remove(String id);

  Future<SavedSearchPreview> preview(String id);
}
