import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// These mirror `utils/functions/profile/profile-completion.test.ts` on the
/// web. The two implementations score the same profile, so they have to agree:
/// the cases below are the web's, with the same expected percentages.
void main() {
  /// Every employee field filled — 25 of them, totalling 100.
  Map<String, dynamic> completeEmployee() => {
        'id': 'e1',
        'firstname': 'Chenda',
        'lastname': 'Nhem',
        'dob': '1996-09-30T00:00:00.000Z',
        'gender': 'female',
        'avatar': 'avatar.png',
        'username': 'chenda_nhem',
        'email': 'chenda@seed.dev',
        'phone': '+85512000007',
        'job': 'Sales Manager',
        'yearsOfExperience': '5 years',
        'availability': 'available',
        'description': 'A bio.',
        'location': 'Phnom Penh',
        'workMode': 'hybrid',
        'noticePeriod': '1 month',
        'portfolioUrl': 'https://example.com',
        'linkedinUrl': 'https://linkedin.com/in/x',
        'languages': ['Khmer', 'English'],
        'skills': [
          {'name': 'Digital Marketing'},
        ],
        'experiences': [
          {'title': 'Sales Representative'},
        ],
        'educations': [
          {'school': 'Build Bright University', 'degree': 'BBM'},
        ],
        'careerScopes': [
          {'name': 'Sales'},
        ],
        'socials': [
          {'platform': 'linkedin', 'url': 'https://linkedin.com/in/x'},
        ],
        'resume': 'resume.pdf',
        'coverLetter': 'cover.pdf',
      };

  Map<String, dynamic> completeCompany() => {
        'id': 'c1',
        'name': 'Sabay Digital',
        'industry': 'Technology',
        'avatar': 'avatar.png',
        'cover': 'cover.png',
        'description': 'A description.',
        'location': 'Phnom Penh',
        'phone': '+85523000001',
        'companySize': 250,
        'foundedYear': 2008,
        'email': 'jobs@sabay.dev',
        'websiteUrl': 'https://sabay.dev',
        'companyType': 'private',
        'openPositions': [
          {'title': 'Digital Marketing Manager'},
        ],
        'benefits': [
          {'label': 'Annual Bonus'},
        ],
        'values': [
          {'label': 'Innovation'},
        ],
        'careerScopes': [
          {'name': 'Software Development'},
        ],
        'socials': [
          {'platform': 'facebook', 'url': 'https://fb.com/sabay'},
        ],
        'images': [
          {'id': 'i1'},
        ],
      };

  test('every employee field filled is 100% with nothing missing', () {
    final completion = EmployeeProfile.fromJson(completeEmployee()).completion;

    expect(completion.percent, 100);
    expect(completion.missing, isEmpty);
    expect(completion.isComplete, isTrue);
    expect(completion.prompt, isNull);
  });

  test('blank strings and empty arrays count as missing', () {
    // The web's case: a whitespace first name and no skills is 87%.
    final completion = EmployeeProfile.fromJson({
      ...completeEmployee(),
      'firstname': '   ',
      'skills': <dynamic>[],
    }).completion;

    expect(completion.percent, 87);
    expect(completion.missing, containsAll(['first name', 'skills']));
  });

  test('expected salary left on the record does not score', () {
    // Expected salary left the employee UI, but the columns are still
    // persisted and still come back. A record carrying them must not be
    // pushed over 100%.
    final completion = EmployeeProfile.fromJson({
      ...completeEmployee(),
      'expectedSalaryMin': 1000,
      'expectedSalaryMax': 2000,
    }).completion;

    expect(completion.percent, 100);
    expect(completion.missing, isEmpty);
  });

  test('every company field filled is 100%', () {
    final completion = CompanyProfile.fromJson(completeCompany()).completion;

    expect(completion.percent, 100);
    expect(completion.missing, isEmpty);
  });

  test('non-positive company numbers count as missing', () {
    final completion = CompanyProfile.fromJson({
      ...completeCompany(),
      'companySize': 0,
      'foundedYear': -1,
    }).completion;

    expect(completion.missing, containsAll(['company size', 'founded year']));
    expect(completion.percent, 100 - 4 - 3);
  });

  test('an empty profile scores zero rather than throwing', () {
    final completion = EmployeeProfile.fromJson({'id': 'e1'}).completion;

    expect(completion.percent, 0);
    expect(completion.missing, hasLength(25));
  });

  test('the prompt names the heaviest missing fields first', () {
    // Open positions carry 14, the heaviest single company field, so it is
    // the first thing worth asking for.
    final completion = CompanyProfile.fromJson({
      ...completeCompany(),
      'openPositions': <dynamic>[],
      'companyType': null,
      'avatar': null,
    }).completion;

    expect(completion.missing.first, 'open positions');
    expect(
      completion.prompt,
      'Add your open positions, profile photo and company type to reach 100%.',
    );
  });

  test('a single missing field reads as one item, not a list', () {
    final completion = EmployeeProfile.fromJson({
      ...completeEmployee(),
      'coverLetter': null,
    }).completion;

    expect(completion.percent, 99);
    expect(completion.prompt, 'Add your cover letter to reach 100%.');
  });
}
