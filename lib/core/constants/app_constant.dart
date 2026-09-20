class AppConstants {
  AppConstants._();

  // =========================
  // APP INFO
  // =========================
  static const String appName = 'Apsara Talent';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Job Matching Platform';

  // =========================
  // TIME CONFIG
  // =========================
  static const int splashDuration = 2;
  static const int apiTimeoutSeconds = 30;
  static const int resendOtpSeconds = 60;

  // =========================
  // AUTH CONFIG
  // =========================
  static const int otpLength = 6;
  static const int pinLength = 6;
  static const int maxLoginAttempts = 5;
  static const int sessionTimeoutMinutes = 15;

  // =========================
  // PASSWORD RULES
  // =========================
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;

  // =========================
  // PAGINATION
  // =========================
  static const int defaultPageSize = 20;
  static const int transactionPageSize = 30;

  // =========================
  // CACHE CONFIG
  // =========================
  static const int cacheExpirationMinutes = 10;
  static const int maxCachedTransactions = 100;

  // =========================
  // NETWORK
  // =========================
  static const int maxRetryAttempts = 3;
  static const int retryDelayMilliseconds = 1500;

  // =========================
  // UI CONFIG
  // =========================
  // Shape, spacing and elevation live in core/themes (AppShape, AppElevation).
  // The UI is square with hard offset shadows, so radius and Material
  // elevation are both 0; these mirror that for anything reading them here.
  static const double defaultBorderRadius = 0;
  static const double defaultPadding = 16;
  static const double cardElevation = 0;

  // =========================
  // FILE / MEDIA
  // =========================
  static const int maxImageSizeMB = 5;
  static const int maxProfileImageSizeMB = 2;

  // =========================
  // NOTIFICATIONS
  // =========================
  static const bool enablePushNotifications = true;

  // =========================
  // SECURITY
  // =========================
  static const bool enableBiometricLogin = true;
  static const bool enablePinLogin = true;
}
