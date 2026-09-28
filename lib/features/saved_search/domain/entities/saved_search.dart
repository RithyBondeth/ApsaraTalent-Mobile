import 'package:apsaratalent_mobile/core/utils/json_parse.dart';

/// How often the API emails new matches for a saved search.
enum SearchFrequency {
  off('Off', 'Saved, but no emails'),
  daily('Daily', 'An email when there are new matches, at most once a day'),
  weekly('Weekly', 'A weekly roundup of new matches');

  const SearchFrequency(this.label, this.description);

  final String label;
  final String description;

  static SearchFrequency fromKey(String? key) {
    for (final f in SearchFrequency.values) {
      if (f.name == key) return f;
    }
    return SearchFrequency.off;
  }
}

/// A search someone kept.
///
/// The API stores `filters` as whatever search DTO it was given. Mobile search
/// only ever sends a keyword and, when narrowing, career scopes — so those are
/// the two read back. A search saved on the web with other filters still loads
/// and lists; running it here applies what this app's search understands.
class SavedSearch {
  const SavedSearch({
    required this.id,
    required this.name,
    required this.frequency,
    this.keyword,
    this.careerScopes = const [],
    this.createdAt,
    this.hasOtherFilters = false,
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    final filters = json['filters'];
    final map = filters is Map ? filters.cast<String, dynamic>() : const {};
    const understood = {'keyword', 'careerScopes'};
    return SavedSearch(
      id: '${json['id']}',
      name: jsonText(json['name']) ?? 'Saved search',
      frequency: SearchFrequency.fromKey(jsonText(json['frequency'])),
      keyword: jsonText(map['keyword']),
      careerScopes: jsonStrings(map['careerScopes']),
      createdAt: DateTime.tryParse(jsonText(json['createdAt']) ?? ''),
      // So the list can say "plus filters set on the web" rather than
      // implying the keyword is the whole search.
      hasOtherFilters: map.keys.any(
        (k) => !understood.contains(k) && map[k] != null,
      ),
    );
  }

  final String id;
  final String name;
  final SearchFrequency frequency;
  final String? keyword;
  final List<String> careerScopes;
  final DateTime? createdAt;
  final bool hasOtherFilters;

  bool get isNarrowed => careerScopes.isNotEmpty;

  SavedSearch copyWith({SearchFrequency? frequency}) => SavedSearch(
        id: id,
        name: name,
        frequency: frequency ?? this.frequency,
        keyword: keyword,
        careerScopes: careerScopes,
        createdAt: createdAt,
        hasOtherFilters: hasOtherFilters,
      );
}

/// How a saved search is doing right now.
class SavedSearchPreview {
  const SavedSearchPreview({required this.total, required this.newCount});

  factory SavedSearchPreview.fromJson(Map<String, dynamic> json) =>
      SavedSearchPreview(
        total: jsonInt(json['totalMatches']) ?? 0,
        newCount: jsonInt(json['newMatchCount']) ?? 0,
      );

  final int total;

  /// New since the digest last ran — not since the viewer last looked.
  final int newCount;
}
