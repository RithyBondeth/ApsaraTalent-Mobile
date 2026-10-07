import 'package:apsaratalent_mobile/core/enums/environment_enum.dart';
import 'package:flutter/foundation.dart';

class AppEnvironmentConfig {
  AppEnvironmentConfig._();

  /// The environment this build was made for.
  ///
  /// `--dart-define=APP_ENV=staging` (or `development`, `production`) wins.
  /// Without one, only a debug build talks to the local API; profile and
  /// release builds are production. Hard-coding development here once meant a
  /// store build would have shipped pointed at `127.0.0.1`.
  static EEnvironmentType fromBuild() => resolve(
        const String.fromEnvironment('APP_ENV'),
        debug: kDebugMode,
      );

  /// A misspelt `APP_ENV` throws rather than falling back: quietly picking an
  /// environment the build did not ask for is how a release reaches the wrong
  /// API.
  @visibleForTesting
  static EEnvironmentType resolve(String define, {required bool debug}) {
    final name = define.trim().toLowerCase();
    if (name.isEmpty) {
      return debug ? EEnvironmentType.development : EEnvironmentType.production;
    }
    return EEnvironmentType.values.firstWhere(
      (env) => env.name == name,
      orElse: () => throw ArgumentError.value(
        define,
        'APP_ENV',
        'Expected one of ${EEnvironmentType.values.map((e) => e.name).join(', ')}',
      ),
    );
  }

  static EEnvironmentType _environment = EEnvironmentType.development;
  static EEnvironmentType get environment => _environment;

  static void setEnvironment(EEnvironmentType env) => _environment = env;

  static String get envFileName {
    switch (_environment) {
      case EEnvironmentType.development:
        return '.env.development';
      case EEnvironmentType.staging:
        return '.env.staging';
      case EEnvironmentType.production:
        return '.env';
    }
  }

  static bool get isDevelopment => _environment == EEnvironmentType.development;
  static bool get isProduction => _environment == EEnvironmentType.production;
  static bool get isStaging => _environment == EEnvironmentType.staging;
}
