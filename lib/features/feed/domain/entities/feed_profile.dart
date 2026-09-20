import 'package:apsaratalent_mobile/core/utils/json_parse.dart';

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
        name: jsonText(json['name']) ?? 'Company',
        avatarUrl: jsonText(json['avatar']),
        location: jsonText(json['location']),
        industry: jsonText(json['industry']),
        description: jsonText(json['description']),
        companySize: jsonInt(json['companySize']),
        foundedYear: jsonInt(json['foundedYear']),
        openPositions: jsonMaps(json['openPositions'])
            .map(FeedOpenPosition.fromJson)
            .where((p) => p.title.isNotEmpty)
            .toList(),
        benefits: jsonLabels(json['benefits'], 'label'),
        values: jsonLabels(json['values'], 'label'),
        careerScopes: jsonLabels(json['careerScopes'], 'name'),
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
        title: jsonText(json['title']) ?? '',
        type: jsonText(json['type']),
        salary: jsonText(json['salary']),
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
        .map(jsonText)
        .whereType<String>()
        .join(' ');
    return FeedEmployee(
      id: '${json['id']}',
      fullName: name.isNotEmpty ? name : (jsonText(json['username']) ?? 'Talent'),
      avatarUrl: jsonText(json['avatar']),
      location: jsonText(json['location']),
      job: jsonText(json['job']),
      description: jsonText(json['description']),
      yearsOfExperience: jsonText(json['yearsOfExperience']),
      availability: jsonText(json['availability']),
      skills: jsonLabels(json['skills'], 'name'),
      careerScopes: jsonLabels(json['careerScopes'], 'name'),
      experiences: jsonMaps(json['experiences'])
          .map((e) => [jsonText(e['title']), jsonText(e['company'])]
              .whereType<String>()
              .join(' · '))
          .where((e) => e.isNotEmpty)
          .toList(),
      educations: jsonMaps(json['educations'])
          .map((e) => [jsonText(e['degree']), jsonText(e['school'])]
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

/// A saved profile, paired with the favourite row that saved it.
///
/// Unfavouriting takes the favourite's own id, not the profile's, so the two
/// have to travel together.
class FavoriteProfile {
  const FavoriteProfile({required this.profile, required this.favoriteId});

  final FeedProfile profile;
  final String favoriteId;
}

/// `full_time` → `Full time`, `available` → `Available`. Values the API
/// already stores as prose ("Full Time") keep their own casing.
String humanize(String value) {
  if (value.isEmpty) return value;
  final spaced =
      value.contains('_') ? value.replaceAll('_', ' ').toLowerCase() : value;
  return spaced[0].toUpperCase() + spaced.substring(1);
}
