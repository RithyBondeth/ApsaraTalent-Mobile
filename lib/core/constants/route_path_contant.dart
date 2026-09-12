class RoutePathConstant {
  RoutePathConstant._();

  // ==================================================
  // AUTH ROUTES
  // ==================================================
  static String loginPath = '/login';
  static String forgotPasswordPath = '/forgot-password';
  static String resetPasswordPath = '/reset-passowrd';
  static String phoneNumberLoginPath = '/phone-number';
  static String phoneOTPPath = '/phone-otp';

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
  static String profilePath = '/profile';
  static String applicationPath = '/application';
  static String favoritePath = '/favorite';
  static String jobDetailPath = '/job';
}
