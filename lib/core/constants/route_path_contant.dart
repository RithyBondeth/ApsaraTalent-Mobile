class RoutePathConstant {
  RoutePathConstant._();

  // ==================================================
  // LAUNCH
  // Restores a remembered session, then routes to home or login.
  // ==================================================
  static String splashPath = '/';

  // ==================================================
  // AUTH ROUTES
  // ==================================================
  static String loginPath = '/login';
  static String forgotPasswordPath = '/forgot-password';
  static String resetPasswordPath = '/reset-passowrd';
  static String phoneNumberLoginPath = '/phone-number';
  static String phoneOTPPath = '/phone-otp';
  static String emailVerificationPath = '/verify-email';

  // ==================================================
  // SIGNUP ROUTES
  // Role, then sign-in details, then profile — the web app's order.
  // ==================================================
  static String signupRolePath = '/signup';
  static String signupAccountPath = '/signup/account';
  static String signupProfilePath = '/signup/profile';

  // ==================================================
  // MAIN ROUTES
  // ==================================================
  static String homePath = '/home';
  static String feedPath = 'feed';
  static String searchPath = 'search';
  static String chatPath = 'chat';
  static String resumeBuilderPath = 'resume-builder';
  static String settingPath = 'setting';

  // ==================================================
  // DETAIL ROUTES
  // Pushed over the tabs rather than into them, so a pinned footer (the job
  // detail's Apply button) never stacks on top of the tab bar.
  // ==================================================
  static String notificationPath = '/notification';
  static String matchPath = '/match';
  static String profileEditPath = '/profile/edit';
  static String profilePath = '/profile';
  static String applicationPath = '/application';
  static String favoritePath = '/favorite';
  static String jobDetailPath = '/job';
  static String twoFactorSettingsPath = '/settings/two-factor';
  static String notificationPreferencesPath = '/settings/notifications';
}
