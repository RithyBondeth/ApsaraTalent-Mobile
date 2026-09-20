import 'package:apsaratalent_mobile/core/utils/json_parse.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart'
    show humanize;

/// The company a posting belongs to, as the job payloads nest it.
class JobCompany {
  const JobCompany({required this.id, required this.name, this.avatarUrl, this.industry, this.location});

  factory JobCompany.fromJson(Map<String, dynamic> json) => JobCompany(
        id: '${json['id']}',
        name: jsonText(json['name']) ?? 'Company',
        avatarUrl: jsonText(json['avatar']),
        industry: jsonText(json['industry']),
        location: jsonText(json['location']),
      );

  final String id;
  final String name;
  final String? avatarUrl;
  final String? industry;
  final String? location;
}

/// A job posting, from either the search list or the single-posting route.
///
/// The two disagree on two field names for the same data: search answers
/// `experience` and `education`, `/public/job/:id` answers
/// `experienceRequired` and `educationRequired`. Both are read here rather
/// than modelled twice.
class JobPosting {
  const JobPosting({
    required this.id,
    required this.title,
    this.description,
    this.type,
    this.salary,
    this.location,
    this.workMode,
    this.experience,
    this.education,
    this.company,
    this.skills = const [],
    this.postedDate,
    this.deadlineDate,
    this.openings,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    final company = json['company'];
    return JobPosting(
      id: '${json['id']}',
      title: jsonText(json['title']) ?? 'Role',
      description: jsonText(json['description']),
      type: jsonText(json['type']),
      salary: jsonText(json['salary']),
      location: jsonText(json['location']),
      workMode: jsonText(json['workMode']),
      // Search says `experience`; the single posting says `experienceRequired`.
      experience:
          jsonText(json['experience']) ?? jsonText(json['experienceRequired']),
      education:
          jsonText(json['education']) ?? jsonText(json['educationRequired']),
      company: company is Map
          ? JobCompany.fromJson(company.cast<String, dynamic>())
          : null,
      // A plain string array, unlike the objects the profile payloads nest.
      skills: jsonStrings(json['skills']),
      postedDate: jsonText(json['postedDate']),
      deadlineDate: jsonText(json['deadlineDate']),
      openings: jsonInt(json['openingsCount']),
    );
  }

  final String id;
  final String title;
  final String? description;

  /// The API's employment type key, e.g. `full_time`.
  final String? type;
  final String? salary;
  final String? location;
  final String? workMode;
  final String? experience;
  final String? education;
  final JobCompany? company;
  final List<String> skills;
  final String? postedDate;
  final String? deadlineDate;
  final int? openings;

  String? get typeLabel => type == null ? null : humanize(type!);
  String? get workModeLabel => workMode == null ? null : humanize(workMode!);

  /// The posting's own location, or the company's when it has none.
  String? get where => location ?? company?.location;
}

/// One page of results.
class SearchResults<T> {
  const SearchResults({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.usedFallback,
  });

  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  /// True when the API asked for a career-scope-narrowed search, found
  /// nothing, and quietly retried **without** the scope filter.
  ///
  /// These results are therefore not narrowed, whatever the viewer asked for.
  /// The screen says so — silently showing unfiltered results as if they were
  /// filtered is the kind of thing nobody notices until they act on it.
  final bool usedFallback;

  bool get hasMore => items.length < total;

  static SearchResults<T> of<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parse,
  ) =>
      SearchResults(
        items: jsonMaps(json['data']).map(parse).toList(),
        total: jsonInt(json['total']) ?? 0,
        page: jsonInt(json['page']) ?? 1,
        pageSize: jsonInt(json['pageSize']) ?? 0,
        usedFallback: json['isUsingFallback'] == true,
      );

  static SearchResults<T> empty<T>() => SearchResults(
        items: const [],
        total: 0,
        page: 1,
        pageSize: 0,
        usedFallback: false,
      );
}
