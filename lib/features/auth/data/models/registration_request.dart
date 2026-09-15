/// What an employee enters at signup.
///
/// Serialises to the API's `EmployeeRegisterDTO` in the same shape the web app
/// sends, so an account made on mobile is indistinguishable from one made on
/// the web. Experience, education, avatar and documents are left to profile
/// editing: the API takes them all as optional, and a nine-step signup on a
/// phone is where people give up.
class EmployeeRegistration {
  const EmployeeRegistration({
    required this.email,
    required this.password,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.gender,
    required this.dob,
    required this.location,
    required this.job,
    required this.yearsOfExperience,
    required this.availability,
    required this.careerScopes,
    required this.skills,
    this.phone,
    this.description,
  });

  final String email;
  final String password;
  final String firstname;
  final String lastname;
  final String username;
  final String gender;
  final DateTime dob;
  final String location;
  final String job;
  final String yearsOfExperience;
  final String availability;
  final List<String> careerScopes;
  final List<String> skills;
  final String? phone;
  final String? description;

  Map<String, dynamic> toJson() => {
        'authEmail': true,
        'email': email.trim(),
        'password': password,
        'firstname': firstname.trim(),
        'lastname': lastname.trim(),
        'username': username.trim(),
        'gender': gender,
        // A date, not a datetime: send UTC midnight of the chosen day so the
        // birthday cannot slide a day either side in a far-off timezone.
        'dob': DateTime.utc(dob.year, dob.month, dob.day).toIso8601String(),
        'location': location,
        if (_hasText(phone)) 'phone': phone!.trim(),
        'job': job.trim(),
        'yearsOfExperience': yearsOfExperience,
        'availability': availability,
        if (_hasText(description)) 'description': description!.trim(),
        // The web sends each skill and scope with its own name as the
        // description; matching reads `name`, so do the same.
        'skills': [
          for (final s in skills) {'name': s, 'description': s},
        ],
        'careerScopes': [
          for (final c in careerScopes) {'name': c, 'description': c},
        ],
        'educations': const <Object>[],
        'experiences': const <Object>[],
        'socials': const <Object>[],
        'languages': const <String>[],
      };
}

/// What a company enters at signup; serialises to `CompanyRegisterDTO`.
class CompanyRegistration {
  const CompanyRegistration({
    required this.email,
    required this.password,
    required this.name,
    required this.description,
    required this.industry,
    required this.location,
    required this.companySize,
    required this.foundedYear,
    required this.careerScopes,
    this.phone,
    this.websiteUrl,
    this.companyType,
  });

  final String email;
  final String password;
  final String name;
  final String description;
  final String industry;
  final String location;
  final int companySize;
  final int foundedYear;
  final List<String> careerScopes;
  final String? phone;
  final String? websiteUrl;
  final String? companyType;

  Map<String, dynamic> toJson() => {
        'authEmail': true,
        'email': email.trim(),
        'password': password,
        if (_hasText(phone)) 'phone': phone!.trim(),
        'name': name.trim(),
        'description': description.trim(),
        'industry': industry.trim(),
        'location': location,
        'companySize': companySize,
        'foundedYear': foundedYear,
        if (_hasText(websiteUrl)) 'websiteUrl': websiteUrl!.trim(),
        if (_hasText(companyType)) 'companyType': companyType,
        'careerScopes': [
          for (final c in careerScopes) {'name': c},
        ],
        // `jobs`, not `openPositions`: the API's whitelist strips unknown keys,
        // and the web's `openPositions` is silently dropped by exactly that.
        'jobs': const <Object>[],
        'benefits': const <Object>[],
        'values': const <Object>[],
        'socials': const <Object>[],
      };
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
