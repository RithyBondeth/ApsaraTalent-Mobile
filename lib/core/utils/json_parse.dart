/// Parsing helpers for API records, shared by every feature that reads one.
///
/// They are deliberately forgiving — a missing list is empty, a missing string
/// is null — because one half-filled record must not take a whole screen down
/// with a type error. A profile that is 40% complete is the normal case here,
/// not an error.
library;

/// A non-blank string, or null. Whitespace-only counts as absent.
String? jsonText(dynamic value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

int? jsonInt(dynamic value) =>
    value is int ? value : (value is String ? int.tryParse(value) : null);

Iterable<Map<String, dynamic>> jsonMaps(dynamic value) => value is List
    ? value.whereType<Map>().map((m) => m.cast<String, dynamic>())
    : const [];

/// The non-blank [key] of every object in a list: `[{name: 'Dart'}]` → `['Dart']`.
List<String> jsonLabels(dynamic value, String key) =>
    jsonMaps(value).map((m) => jsonText(m[key])).whereType<String>().toList();

/// A list of plain strings, as TypeORM's `simple-array` columns return.
List<String> jsonStrings(dynamic value) => value is List
    ? value.map(jsonText).whereType<String>().toList()
    : const [];
