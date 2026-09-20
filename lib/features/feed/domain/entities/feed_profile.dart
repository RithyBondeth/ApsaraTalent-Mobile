/// A card in the feed: a company when an employee is looking, an employee when
/// a company is.
///
/// Both come straight from the API's profile records. Parsing is deliberately
/// forgiving — a missing list is empty, a missing string is null — because one
/// half-filled profile must not take the whole feed down with a type error.
sealed class FeedProfile {
  const FeedProfile({required this.id, this.avatarUrl, this.location});

  /// The employee's or company's own id — what matching and favourites take.
  final String id;
  final String? avatarUrl;
  final String? location;

  /// A company's name, or an employee's full name (falling back to username).
  String get displayName;
}

class FeedCompany extends FeedProfile {
  const FeedCompany({
    required super.id,
    required this.name,
    super.avatarUrl,
    super.location,
    this.industry,
    this.description,
    this.companySize,
    this.foundedYear,
    this.openPositions = const [],
    this.benefits = const [],
    this.values = const [],
    this.careerScopes = const [],
  });

  factory FeedCompany.fromJson(Map<String, dynamic> json) => FeedCompany(
        id: '${json['id']}',
        name: _text(json['name']) ?? 'Company',
        avatarUrl: _text(json['avatar']),
        location: _text(json['location']),
        industry: _text(json['industry']),
        description: _text(json['description']),
        companySize: _integer(json['companySize']),
        foundedYear: _integer(json['foundedYear']),
        openPositions: _maps(json['openPositions'])
            .map(FeedOpenPosition.fromJson)
            .where((p) => p.title.isNotEmpty)
            .toList(),
        benefits: _labels(json['benefits'], 'label'),
        values: _labels(json['values'], 'label'),
        careerScopes: _labels(json['careerScopes'], 'name'),
      );

  final String name;
  final String? industry;
  final String? description;
  final int? companySize;
  final int? foundedYear;
  final List<FeedOpenPosition> openPositions;
  final List<String> benefits;
  final List<String> values;
  final List<String> careerScopes;

  @override
  String get displayName => name;
}

class FeedOpenPosition {
  const FeedOpenPosition({required this.title, this.type, this.salary});

  factory FeedOpenPosition.fromJson(Map<String, dynamic> json) =>
      FeedOpenPosition(
        title: _text(json['title']) ?? '',
        type: _text(json['type']),
        salary: _text(json['salary']),
      );

  final String title;

  /// The API's employment type key, e.g. `full_time`. See [humanize].
  final String? type;
  final String? salary;
}

class FeedEmployee extends FeedProfile {
  const FeedEmployee({
    required super.id,
    required this.fullName,
    super.avatarUrl,
    super.location,
    this.job,
    this.description,
    this.yearsOfExperience,
    this.availability,
    this.skills = const [],
    this.careerScopes = const [],
    this.experiences = const [],
    this.educations = const [],
  });

  factory FeedEmployee.fromJson(Map<String, dynamic> json) {
    final name = [json['firstname'], json['lastname']]
        .map(_text)
        .whereType<String>()
        .join(' ');
    return FeedEmployee(
      id: '${json['id']}',
      fullName: name.isNotEmpty ? name : (_text(json['username']) ?? 'Talent'),
      avatarUrl: _text(json['avatar']),
      location: _text(json['location']),
      job: _text(json['job']),
      description: _text(json['description']),
      yearsOfExperience: _text(json['yearsOfExperience']),
      availability: _text(json['availability']),
      skills: _labels(json['skills'], 'name'),
      careerScopes: _labels(json['careerScopes'], 'name'),
      experiences: _maps(json['experiences'])
          .map((e) => [_text(e['title']), _text(e['company'])]
              .whereType<String>()
              .join(' · '))
          .where((e) => e.isNotEmpty)
          .toList(),
      educations: _maps(json['educations'])
          .map((e) => [_text(e['degree']), _text(e['school'])]
              .whereType<String>()
              .join(' · '))
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }

  final String fullName;
  final String? job;
  final String? description;
  final String? yearsOfExperience;

  /// The API's key, e.g. `full_time`. See [humanize].
  final String? availability;
  final List<String> skills;
  final List<String> careerScopes;

  /// "Title · Company", in the order the API returns them.
  final List<String> experiences;

  /// "Degree · School".
  final List<String> educations;

  @override
  String get displayName => fullName;
}

/// `full_time` → `Full time`, `available` → `Available`. Values the API
/// already stores as prose ("Full Time") keep their own casing.
String humanize(String value) {
  if (value.isEmpty) return value;
  final spaced =
      value.contains('_') ? value.replaceAll('_', ' ').toLowerCase() : value;
  return spaced[0].toUpperCase() + spaced.substring(1);
}

String? _text(dynamic value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

int? _integer(dynamic value) =>
    value is int ? value : (value is String ? int.tryParse(value) : null);

Iterable<Map<String, dynamic>> _maps(dynamic value) => value is List
    ? value.whereType<Map>().map((m) => m.cast<String, dynamic>())
    : const [];

List<String> _labels(dynamic value, String key) =>
    _maps(value).map((m) => _text(m[key])).whereType<String>().toList();
