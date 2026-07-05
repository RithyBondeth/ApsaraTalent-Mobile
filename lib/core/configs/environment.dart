import 'package:apsaratalent_mobile/core/enums/environment_enum.dart';

class AppEnvironmentConfig {
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
        return '.env.production';
    }
  }

  static bool get isDevelopment => _environment == EEnvironmentType.development;
  static bool get isProduction => _environment == EEnvironmentType.production;
  static bool get isStaging => _environment == EEnvironmentType.staging;
}
