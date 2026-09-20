import 'package:apsaratalent_mobile/core/utils/json_parse.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/profile_completion.dart';

/// The signed-in user's own profile, in full.
///
/// This is a richer record than the feed's card summary: it carries the
/// contact details, the documents and the links that only the owner sees, and
/// that profile completion is scored against.
sealed class UserProfile {
  const UserProfile({
    required this.id,
    this.avatarUrl,
    this.location,
    this.email,
    this.phone,
  });

  final String id;
  final String? avatarUrl;
  final String? location;
  final String? email;
  final String? phone;

  String get displayName;

  /// A one-line description beneath the name: a job title, or an industry.
  String? get headline;

  ProfileCompletion get completion;
}

class EmployeeProfile extends UserProfile {
  const EmployeeProfile({
    required super.id,
    required this.fullName,
    this.username,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.job,
    this.yearsOfExperience,
    this.availability,
    this.description,
    this.workMode,
    this.noticePeriod,
    this.portfolioUrl,
    this.linkedinUrl,
    this.resume,
    this.coverLetter,
    this.languages = const [],
    this.skills = const [],
    this.careerScopes = const [],
    this.experiences = const [],
    this.educations = const [],
    this.socials = const [],
    super.avatarUrl,
    super.location,
    super.email,
    super.phone,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    final first = jsonText(json['firstname']);
    final last = jsonText(json['lastname']);
    final name = [first, last].whereType<String>().join(' ');
    return EmployeeProfile(
      id: '${json['id']}',
      fullName: name.isNotEmpty ? name : (jsonText(json['username']) ?? 'You'),
      firstName: first,
      lastName: last,
      username: jsonText(json['username']),
      dateOfBirth: jsonText(json['dob']),
      gender: jsonText(json['gender']),
      avatarUrl: jsonText(json['avatar']),
      job: jsonText(json['job']),
      yearsOfExperience: jsonText(json['yearsOfExperience']),
      availability: jsonText(json['availability']),
      description: jsonText(json['description']),
      location: jsonText(json['location']),
      email: jsonText(json['email']),
      phone: jsonText(json['phone']),
      workMode: jsonText(json['workMode']),
      noticePeriod: jsonText(json['noticePeriod']),
      portfolioUrl: jsonText(json['portfolioUrl']),
      linkedinUrl: jsonText(json['linkedinUrl']),
      resume: jsonText(json['resume']),
      coverLetter: jsonText(json['coverLetter']),
      // A TypeORM `simple-array` column: a list of plain strings, or null.
      languages: jsonStrings(json['languages']),
      skills: jsonLabels(json['skills'], 'name'),
      careerScopes: jsonLabels(json['careerScopes'], 'name'),
      experiences: jsonMaps(json['experiences'])
          .map(ProfileExperience.fromJson)
          .where((e) => e.title != null)
          .toList(),
      educations: jsonMaps(json['educations'])
          .map(ProfileEducation.fromJson)
          .where((e) => e.school != null || e.degree != null)
          .toList(),
      socials: jsonMaps(json['socials'])
          .map(ProfileSocial.fromJson)
          .where((s) => s.url != null)
          .toList(),
    );
  }

  final String fullName;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? dateOfBirth;
  final String? gender;
  final String? job;
  final String? yearsOfExperience;

  /// The API's key, e.g. `available`. See `humanize`.
  final String? availability;
  final String? description;
  final String? workMode;
  final String? noticePeriod;
  final String? portfolioUrl;
  final String? linkedinUrl;
  final String? resume;
  final String? coverLetter;
  final List<String> languages;
  final List<String> skills;
  final List<String> careerScopes;
  final List<ProfileExperience> experiences;
  final List<ProfileEducation> educations;
  final List<ProfileSocial> socials;

  @override
  String get displayName => fullName;

  @override
  String? get headline => job;

  /// 25 weighted fields totalling 100, matching the web exactly.
  ///
  /// Expected salary is **not** scored. The columns are still on the record
  /// and still come back in the payload, but they left the employee UI, and a
  /// record that still carries them must not be pushed over 100%.
  @override
  ProfileCompletion get completion => ProfileCompletion.of([
        ProfileField('first name', 3, filled: firstName != null),
        ProfileField('last name', 3, filled: lastName != null),
        ProfileField('date of birth', 3, filled: dateOfBirth != null),
        ProfileField('gender', 2, filled: gender != null),
        ProfileField('profile photo', 6, filled: avatarUrl != null),
        ProfileField('username', 3, filled: username != null),
        ProfileField('email', 4, filled: email != null),
        ProfileField('phone number', 4, filled: phone != null),
        ProfileField('job title', 6, filled: job != null),
        ProfileField('years of experience', 4, filled: yearsOfExperience != null),
        ProfileField('availability', 4, filled: availability != null),
        ProfileField('bio', 6, filled: description != null),
        ProfileField('location', 4, filled: location != null),
        ProfileField('work mode', 3, filled: workMode != null),
        ProfileField('notice period', 3, filled: noticePeriod != null),
        ProfileField('portfolio link', 3, filled: portfolioUrl != null),
        ProfileField('LinkedIn link', 3, filled: linkedinUrl != null),
        ProfileField('languages', 4, filled: languages.isNotEmpty),
        // Carries the 4% expected salary used to hold: skills are what
        // companies match on, so the weight belongs here.
        ProfileField('skills', 10, filled: skills.isNotEmpty),
        ProfileField('work history', 6, filled: experiences.isNotEmpty),
        ProfileField('education', 6, filled: educations.isNotEmpty),
        ProfileField('career scopes', 4, filled: careerScopes.isNotEmpty),
        ProfileField('social links', 3, filled: socials.isNotEmpty),
        ProfileField('résumé', 2, filled: resume != null),
        ProfileField('cover letter', 1, filled: coverLetter != null),
      ]);
}

class CompanyProfile extends UserProfile {
  const CompanyProfile({
    required super.id,
    required this.name,
    this.industry,
    this.description,
    this.coverUrl,
    this.websiteUrl,
    this.companyType,
    this.companySize,
    this.foundedYear,
    this.openPositions = const [],
    this.benefits = const [],
    this.values = const [],
    this.careerScopes = const [],
    this.images = 0,
    this.socials = const [],
    super.avatarUrl,
    super.location,
    super.email,
    super.phone,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) => CompanyProfile(
        id: '${json['id']}',
        name: jsonText(json['name']) ?? 'Your company',
        industry: jsonText(json['industry']),
        description: jsonText(json['description']),
        avatarUrl: jsonText(json['avatar']),
        coverUrl: jsonText(json['cover']),
        location: jsonText(json['location']),
        email: jsonText(json['email']),
        phone: jsonText(json['phone']),
        websiteUrl: jsonText(json['websiteUrl']),
        companyType: jsonText(json['companyType']),
        companySize: jsonInt(json['companySize']),
        foundedYear: jsonInt(json['foundedYear']),
        openPositions: jsonLabels(json['openPositions'], 'title'),
        benefits: jsonLabels(json['benefits'], 'label'),
        values: jsonLabels(json['values'], 'label'),
        careerScopes: jsonLabels(json['careerScopes'], 'name'),
        images: jsonMaps(json['images']).length,
        socials: jsonMaps(json['socials'])
            .map(ProfileSocial.fromJson)
            .where((s) => s.url != null)
            .toList(),
      );

  final String name;
  final String? industry;
  final String? description;
  final String? coverUrl;
  final String? websiteUrl;
  final String? companyType;
  final int? companySize;
  final int? foundedYear;
  final List<String> openPositions;
  final List<String> benefits;
  final List<String> values;
  final List<String> careerScopes;

  /// Only the count is scored, and the gallery is not on this screen yet.
  final int images;
  final List<ProfileSocial> socials;

  @override
  String get displayName => name;

  @override
  String? get headline => industry;

  /// 18 weighted fields totalling 100, matching the web exactly. A count of
  /// zero or less is missing, not present — the web checks `> 0`.
  @override
  ProfileCompletion get completion => ProfileCompletion.of([
        ProfileField('company name', 5, filled: name.isNotEmpty),
        ProfileField('industry', 4, filled: industry != null),
        ProfileField('profile photo', 7, filled: avatarUrl != null),
        ProfileField('cover image', 5, filled: coverUrl != null),
        ProfileField('description', 8, filled: description != null),
        ProfileField('location', 5, filled: location != null),
        ProfileField('phone number', 4, filled: phone != null),
        ProfileField('company size', 4,
            filled: companySize != null && companySize! > 0),
        ProfileField('founded year', 3,
            filled: foundedYear != null && foundedYear! > 0),
        ProfileField('email', 4, filled: email != null),
        ProfileField('website', 4, filled: websiteUrl != null),
        ProfileField('company type', 3, filled: companyType != null),
        ProfileField('open positions', 14, filled: openPositions.isNotEmpty),
        ProfileField('benefits', 5, filled: benefits.isNotEmpty),
        ProfileField('values', 5, filled: values.isNotEmpty),
        ProfileField('career scopes', 6, filled: careerScopes.isNotEmpty),
        ProfileField('social links', 7, filled: socials.isNotEmpty),
        ProfileField('company photos', 7, filled: images > 0),
      ]);
}

class ProfileExperience {
  const ProfileExperience({this.title, this.company, this.description});

  factory ProfileExperience.fromJson(Map<String, dynamic> json) =>
      ProfileExperience(
        title: jsonText(json['title']),
        company: jsonText(json['company']),
        description: jsonText(json['description']),
      );

  final String? title;
  final String? company;
  final String? description;

  /// "Title · Company", or just whichever of the two the record has.
  String get summary =>
      [title, company].whereType<String>().join(' · ');
}

class ProfileEducation {
  const ProfileEducation({this.school, this.degree, this.year});

  factory ProfileEducation.fromJson(Map<String, dynamic> json) =>
      ProfileEducation(
        school: jsonText(json['school']),
        degree: jsonText(json['degree']),
        year: jsonText(json['year']),
      );

  final String? school;
  final String? degree;
  final String? year;

  String get summary => [degree, school].whereType<String>().join(' · ');
}

class ProfileSocial {
  const ProfileSocial({this.platform, this.url});

  factory ProfileSocial.fromJson(Map<String, dynamic> json) => ProfileSocial(
        platform: jsonText(json['platform']),
        url: jsonText(json['url']),
      );

  final String? platform;
  final String? url;
}
