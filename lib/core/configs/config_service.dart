import 'package:apsaratalent_mobile/core/configs/environment.dart';
import 'package:apsaratalent_mobile/core/enums/environment_enum.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static Future<void> initialize(EEnvironmentType env) async {
    AppEnvironmentConfig.setEnvironment(env);
    await dotenv.load(fileName: AppEnvironmentConfig.envFileName);
  }

  static String get appName =>
      dotenv.get('APP_NAME', fallback: 'Apsara Talent');
  static String get apiBaseUrl => dotenv.get('API_BASE_URL', fallback: '');
  static bool get debugMode =>
      dotenv.get('DEBUG_MODE', fallback: 'false').toLowerCase() == 'true';

  // Alternative methods for accessing variables in v6.0.0:

  // Using maybeGet (returns null if not found)
  //static String? get optionalValue => dotenv.maybeGet('OPTIONAL_VALUE');

  // Using [] operator (throws if not found)
  //static String get requiredValue => dotenv['REQUIRED_VALUE'];

  // Check if variable exists
  //static bool hasApiKey => dotenv.isEveryDefined(['API_KEY']);
}
