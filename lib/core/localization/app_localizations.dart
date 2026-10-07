import 'khmer_product_copy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Small, source-string based localization catalog.
///
/// API and user supplied values pass through unchanged. Product copy uses its
/// English source as the stable key, which lets shared UI primitives localize
/// existing screens without coupling feature code to generated key names.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('km')];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      const AppLocalizations(Locale('en'));

  bool get isKhmer => locale.languageCode == 'km';

  String translate(String source,
      [Map<String, Object?> parameters = const {}]) {
    var text =
        isKhmer ? (khmerProductCopy[source] ?? _km[source] ?? source) : source;
    for (final e in parameters.entries) {
      text = text.replaceAll('{${e.key}}', '${e.value ?? ''}');
    }
    return text;
  }

  static const delegate = _AppLocalizationsDelegate();

  static const _km = <String, String>{
    'Feed': 'ទំព័រដើម',
    'Search': 'ស្វែងរក',
    'Chat': 'សារ',
    'Resume': 'ប្រវត្តិរូប',
    'Setting': 'ការកំណត់',
    'Settings': 'ការកំណត់',
    'Account and preferences': 'គណនី និងចំណូលចិត្ត',
    'How the app looks, what it tells you about, and who can see your profile.':
        'រូបរាងកម្មវិធី ការជូនដំណឹង និងអ្នកដែលអាចមើលប្រវត្តិរូបរបស់អ្នក។',
    'Your account': 'គណនីរបស់អ្នក',
    'Appearance': 'រូបរាង',
    'The palette is contrast-solved in both themes':
        'ពណ៌មានភាពច្បាស់ល្អទាំងរបៀបភ្លឺ និងងងឹត',
    'System': 'តាមប្រព័ន្ធ',
    'Match device': 'តាមឧបករណ៍',
    'Follows your system setting': 'ប្រើតាមការកំណត់របស់ឧបករណ៍',
    'Light': 'ភ្លឺ',
    'White page, warm-grey ink': 'ផ្ទៃពណ៌ស និងអក្សរប្រផេះ',
    'Dark': 'ងងឹត',
    'Near-black page with layered surfaces': 'ផ្ទៃងងឹតជាមួយស្រទាប់ច្បាស់',
    'Activity': 'សកម្មភាព',
    'Open positions': 'មុខតំណែងបើកទទួល',
    'Create and manage job listings': 'បង្កើត និងគ្រប់គ្រងការងារ',
    'Hiring workflow': 'ដំណើរការជ្រើសរើស',
    'Applications': 'ពាក្យស្នើសុំ',
    'Saved': 'បានរក្សាទុក',
    'Companies and talent you saved': 'ក្រុមហ៊ុន និងបេក្ខជនដែលអ្នកបានរក្សា',
    'Interviews': 'សម្ភាសន៍',
    'Schedule, details, and response status':
        'កាលវិភាគ ព័ត៌មាន និងស្ថានភាពឆ្លើយតប',
    'Notifications': 'ការជូនដំណឹង',
    'Account': 'គណនី',
    'Two-step verification': 'ការផ្ទៀងផ្ទាត់ពីរជំហាន',
    'On': 'បើក',
    'Off': 'បិទ',
    'Email and push, by category': 'អ៊ីមែល និងការជូនដំណឹងតាមប្រភេទ',
    'Blocked accounts': 'គណនីដែលបានទប់ស្កាត់',
    'Who you stopped seeing': 'អ្នកដែលអ្នកបានឈប់មើលឃើញ',
    'Privacy': 'ឯកជនភាព',
    'Private browsing and profile views': 'ការរុករកឯកជន និងការមើលប្រវត្តិរូប',
    'Language': 'ភាសា',
    'English': 'English',
    'Khmer': 'ភាសាខ្មែរ',
    'Support': 'ជំនួយ',
    'Account data': 'ទិន្នន័យគណនី',
    'Export data or delete your account': 'នាំចេញទិន្នន័យ ឬលុបគណនី',
    'Account deletion is scheduled': 'បានកំណត់ពេលលុបគណនី',
    'Log out': 'ចាកចេញ',
    'Choose language': 'ជ្រើសរើសភាសា',
    'App language': 'ភាសាកម្មវិធី',
    'Select the language used throughout Apsara Talent.':
        'ជ្រើសរើសភាសាដែលប្រើក្នុង Apsara Talent។',
    'Language updated': 'បានប្តូរភាសា',
    'Use English throughout the app': 'ប្រើភាសាអង់គ្លេសក្នុងកម្មវិធី',
    'ប្រើភាសាខ្មែរនៅទូទាំងកម្មវិធី': 'ប្រើភាសាខ្មែរនៅទូទាំងកម្មវិធី',
    'Back': 'ត្រឡប់ក្រោយ',
    'Continue': 'បន្ត',
    'Cancel': 'បោះបង់',
    'Save': 'រក្សាទុក',
    'Delete': 'លុប',
    'Edit': 'កែសម្រួល',
    'Add': 'បន្ថែម',
    'Close': 'បិទ',
    'Done': 'រួចរាល់',
    'Retry': 'ព្យាយាមម្តងទៀត',
    'Refresh': 'ផ្ទុកឡើងវិញ',
    'View': 'មើល',
    'View all': 'មើលទាំងអស់',
    'Loading…': 'កំពុងផ្ទុក…',
    'Something went wrong': 'មានបញ្ហាកើតឡើង',
    'No results found': 'រកមិនឃើញលទ្ធផល',
    'Email': 'អ៊ីមែល',
    'Password': 'ពាក្យសម្ងាត់',
    'Sign in': 'ចូលគណនី',
    'Log in': 'ចូលគណនី',
    'Log in to your account': 'ចូលគណនីរបស់អ្នក',
    'Welcome back to Apsara Talent. Choose how you want to sign in.':
        'សូមស្វាគមន៍មកកាន់ Apsara Talent។ ជ្រើសរើសវិធីចូលគណនី។',
    "Don't have an account yet? ": 'មិនទាន់មានគណនីមែនទេ? ',
    'or continue with': 'ឬបន្តដោយ',
    'Remember me': 'ចងចាំខ្ញុំ',
    'Sign up': 'បង្កើតគណនី',
    'Forgot password?': 'ភ្លេចពាក្យសម្ងាត់?',
    'Create account': 'បង្កើតគណនី',
    'Phone number': 'លេខទូរស័ព្ទ',
    'Verify': 'ផ្ទៀងផ្ទាត់',
    'Send code': 'ផ្ញើលេខកូដ',
    'Reset password': 'កំណត់ពាក្យសម្ងាត់ឡើងវិញ',
    'Full name': 'ឈ្មោះពេញ',
    'Company': 'ក្រុមហ៊ុន',
    'Employee': 'បុគ្គលិក',
    'Jobs': 'ការងារ',
    'Messages': 'សារ',
    'Profile': 'ប្រវត្តិរូប',
    'Matches': 'ការផ្គូផ្គង',
    'Favorites': 'ចំណូលចិត្ត',
    'Location': 'ទីតាំង',
    'Skills': 'ជំនាញ',
    'Experience': 'បទពិសោធន៍',
    'Education': 'ការអប់រំ',
    'About': 'អំពី',
    'Contact': 'ទំនាក់ទំនង',
    'Apply': 'ដាក់ពាក្យ',
    'Applied': 'បានដាក់ពាក្យ',
    'Pending': 'កំពុងរង់ចាំ',
    'Accepted': 'បានទទួល',
    'Rejected': 'បានបដិសេធ',
    'Active': 'សកម្ម',
    'Draft': 'សេចក្តីព្រាង',
    'Closed': 'បានបិទ',
    'Create job': 'បង្កើតការងារ',
    'Edit job': 'កែសម្រួលការងារ',
    'Job details': 'ព័ត៌មានការងារ',
    'Interview schedule': 'កាលវិភាគសម្ភាសន៍',
    'No interviews yet': 'មិនទាន់មានសម្ភាសន៍',
    'No notifications yet': 'មិនទាន់មានការជូនដំណឹង',
    'No messages yet': 'មិនទាន់មានសារ',
    'Search jobs and people': 'ស្វែងរកការងារ និងមនុស្ស',
    'Nothing matches your search': 'គ្មានលទ្ធផលត្រូវនឹងការស្វែងរក',
    'selected': 'បានជ្រើសរើស',
    'Type a message': 'សរសេរសារ',
    'Today': 'ថ្ងៃនេះ',
    'Tomorrow': 'ថ្ងៃស្អែក',
    'AI match tools': 'ឧបករណ៍ផ្គូផ្គង AI',
    'Build a resume from your profile':
        'បង្កើតប្រវត្តិរូបការងារពីប្រវត្តិរូបរបស់អ្នក',
    'Channels': 'បណ្តាញ',
    'Control how you browse': 'គ្រប់គ្រងរបៀបរុករករបស់អ្នក',
    'Data and account lifecycle': 'ទិន្នន័យ និងវដ្តជីវិតគណនី',
    'Employer analytics': 'ការវិភាគរបស់និយោជក',
    'Hiring at a glance': 'ទិដ្ឋភាពសង្ខេបនៃការជ្រើសរើស',
    'Hiring': 'ការជ្រើសរើស',
    'Job alerts': 'ការជូនដំណឹងការងារ',
    'Resume builder': 'ឧបករណ៍បង្កើតប្រវត្តិរូបការងារ',
    'Return to the searches that matter': 'ត្រឡប់ទៅការស្វែងរកសំខាន់ៗ',
    'What happened while you were away': 'អ្វីដែលបានកើតឡើងពេលអ្នកមិននៅ',
    'What reaches you, and how': 'អ្វីដែលជូនដំណឹងអ្នក និងតាមវិធីណា',
    'Where every application stands': 'ស្ថានភាពពាក្យស្នើសុំទាំងអស់',
    'Your conversations': 'ការសន្ទនារបស់អ្នក',
    'Your upcoming conversations': 'ការសន្ទនាខាងមុខរបស់អ្នក',
    'Accounts you blocked': 'គណនីដែលអ្នកបានទប់ស្កាត់',
    'Report a problem': 'រាយការណ៍បញ្ហា',
    'No conversations yet': 'មិនទាន់មានការសន្ទនា',
    'No interviews scheduled': 'មិនមានសម្ភាសន៍ដែលបានកំណត់ពេល',
    'No matches yet': 'មិនទាន់មានការផ្គូផ្គង',
    'No open positions': 'មិនមានមុខតំណែងបើកទទួល',
    'No saved searches': 'មិនមានការស្វែងរកដែលបានរក្សាទុក',
    'Nobody blocked': 'មិនមានអ្នកត្រូវបានទប់ស្កាត់',
    'Nothing matched': 'មិនមានអ្វីត្រូវគ្នា',
    'Nothing new': 'មិនមានអ្វីថ្មី',
    'Nothing saved yet': 'មិនទាន់មានអ្វីបានរក្សាទុក',
    'No applications yet': 'មិនទាន់មានពាក្យស្នើសុំ',
    'No applicants for this role': 'មិនមានបេក្ខជនសម្រាប់តួនាទីនេះ',
    'Results appear as you type.': 'លទ្ធផលនឹងបង្ហាញនៅពេលអ្នកវាយបញ្ចូល។',
    'Try a different word, or fewer of them.':
        'សាកពាក្យផ្សេង ឬប្រើពាក្យតិចជាងនេះ។',
    'Try again': 'ព្យាយាមម្តងទៀត',
    'The feed could not load': 'មិនអាចផ្ទុកទំព័រដើមបាន',
    'That search could not run': 'មិនអាចស្វែងរកបាន',
    'Your applications could not load': 'មិនអាចផ្ទុកពាក្យស្នើសុំរបស់អ្នកបាន',
    'Your interviews could not load': 'មិនអាចផ្ទុកសម្ភាសន៍របស់អ្នកបាន',
    'Your matches could not load': 'មិនអាចផ្ទុកការផ្គូផ្គងរបស់អ្នកបាន',
    'Your notifications could not load': 'មិនអាចផ្ទុកការជូនដំណឹងរបស់អ្នកបាន',
    'Your profile could not load': 'មិនអាចផ្ទុកប្រវត្តិរូបរបស់អ្នកបាន',
    'Your saved searches could not load':
        'មិនអាចផ្ទុកការស្វែងរកដែលបានរក្សាទុកបាន',
    'The applicant pipeline could not load': 'មិនអាចផ្ទុកដំណើរការបេក្ខជនបាន',
    'The blocked list could not load': 'មិនអាចផ្ទុកបញ្ជីទប់ស្កាត់បាន',
    'Positions could not load': 'មិនអាចផ្ទុកមុខតំណែងបាន',
    'Interviews could not load': 'មិនអាចផ្ទុកសម្ភាសន៍បាន',
    'Recommendations are unavailable': 'មិនមានការណែនាំនៅពេលនេះ',
    'Company account required': 'ត្រូវការគណនីក្រុមហ៊ុន',
    'No company profile': 'មិនមានប្រវត្តិរូបក្រុមហ៊ុន',
    'New applications will appear here automatically.':
        'ពាក្យស្នើសុំថ្មីនឹងបង្ហាញនៅទីនេះដោយស្វ័យប្រវត្តិ។',
    'New interview invitations will appear here.':
        'ការអញ្ជើញសម្ភាសន៍ថ្មីនឹងបង្ហាញនៅទីនេះ។',
    'Open a mutual match to start a conversation.':
        'បើកការផ្គូផ្គងគ្នាដើម្បីចាប់ផ្តើមការសន្ទនា។',
    'A match means you both said yes. Start the conversation.':
        'ការផ្គូផ្គងមានន័យថាអ្នកទាំងពីរបានយល់ព្រម។ ចាប់ផ្តើមសន្ទនា។',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .any((x) => x.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String source, [Map<String, Object?> parameters = const {}]) =>
      l10n.translate(source, parameters);
}
