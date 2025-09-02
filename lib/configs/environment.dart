enum Environment { development, staging, production }

class AppEnvironmentConfig {
  static Environment _environment = Environment.development;
  static Environment get environment => _environment;

  static void setEnvironment(Environment env) => _environment = env;

  static String get envFileName {
    switch (_environment) {
      case Environment.development:
        return '.env.development';
      case Environment.staging:
        return '.env.staging';
      case Environment.production:
        return '.env.production';
    }
  }

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isProduction => _environment == Environment.production;
  static bool get isStaging => _environment == Environment.staging;
}
