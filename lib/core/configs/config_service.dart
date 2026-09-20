import 'package:apsaratalent_mobile/core/configs/environment.dart';
import 'package:apsaratalent_mobile/core/enums/environment_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfigService {
  AppConfigService._();

  static Future<void> initialize(EEnvironmentType env) async {
    AppEnvironmentConfig.setEnvironment(env);
    await dotenv.load(fileName: AppEnvironmentConfig.envFileName);
  }

  static String get appName =>
      dotenv.get('APP_NAME', fallback: 'Apsara Talent');

  /// The API base URL, with one platform correction.
  ///
  /// An Android emulator is its own device: `127.0.0.1` there is the emulator
  /// itself, not the machine running the API, so a development build reaches
  /// nothing. The host is `10.0.2.2` from inside the emulator.
  ///
  /// Only a loopback host is rewritten. `.env.staging` and `.env` point at
  /// Railway, so this can never touch them — and an iOS simulator shares the
  /// host's network, so it is left alone.
  static String get apiBaseUrl {
    final configured = dotenv.get('API_BASE_URL', fallback: '');
    if (defaultTargetPlatform != TargetPlatform.android || kIsWeb) {
      return configured;
    }
    return configured.replaceFirst(
      RegExp(r'//(127\.0\.0\.1|localhost)(?=[:/]|$)'),
      '//10.0.2.2',
    );
  }

  static bool get debugMode =>
      dotenv.get('DEBUG_MODE', fallback: 'false').toLowerCase() == 'true';
}
