// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_route.dart';

/// generated route for
/// [ApplicationScreen]
class ApplicationRoute extends PageRouteInfo<void> {
  const ApplicationRoute({List<PageRouteInfo>? children})
    : super(ApplicationRoute.name, initialChildren: children);

  static const String name = 'ApplicationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ApplicationScreen();
    },
  );
}

/// generated route for
/// [ChatScreen]
class ChatRoute extends PageRouteInfo<void> {
  const ChatRoute({List<PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChatScreen();
    },
  );
}

/// generated route for
/// [EmailVerificationScreen]
class EmailVerificationRoute extends PageRouteInfo<EmailVerificationRouteArgs> {
  EmailVerificationRoute({
    Key? key,
    required String email,
    bool fromSignup = false,
    bool sendCode = false,
    List<PageRouteInfo>? children,
  }) : super(
         EmailVerificationRoute.name,
         args: EmailVerificationRouteArgs(
           key: key,
           email: email,
           fromSignup: fromSignup,
           sendCode: sendCode,
         ),
         initialChildren: children,
       );

  static const String name = 'EmailVerificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EmailVerificationRouteArgs>();
      return EmailVerificationScreen(
        key: args.key,
        email: args.email,
        fromSignup: args.fromSignup,
        sendCode: args.sendCode,
      );
    },
  );
}

class EmailVerificationRouteArgs {
  const EmailVerificationRouteArgs({
    this.key,
    required this.email,
    this.fromSignup = false,
    this.sendCode = false,
  });

  final Key? key;

  final String email;

  final bool fromSignup;

  final bool sendCode;

  @override
  String toString() {
    return 'EmailVerificationRouteArgs{key: $key, email: $email, fromSignup: $fromSignup, sendCode: $sendCode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EmailVerificationRouteArgs) return false;
    return key == other.key &&
        email == other.email &&
        fromSignup == other.fromSignup &&
        sendCode == other.sendCode;
  }

  @override
  int get hashCode =>
      key.hashCode ^ email.hashCode ^ fromSignup.hashCode ^ sendCode.hashCode;
}

/// generated route for
/// [FavoriteScreen]
class FavoriteRoute extends PageRouteInfo<void> {
  const FavoriteRoute({List<PageRouteInfo>? children})
    : super(FavoriteRoute.name, initialChildren: children);

  static const String name = 'FavoriteRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FavoriteScreen();
    },
  );
}

/// generated route for
/// [FeedScreen]
class FeedRoute extends PageRouteInfo<void> {
  const FeedRoute({List<PageRouteInfo>? children})
    : super(FeedRoute.name, initialChildren: children);

  static const String name = 'FeedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FeedScreen();
    },
  );
}

/// generated route for
/// [ForgotPasswordScreen]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [JobDetailScreen]
class JobDetailRoute extends PageRouteInfo<JobDetailRouteArgs> {
  JobDetailRoute({
    Key? key,
    required SampleJob job,
    List<PageRouteInfo>? children,
  }) : super(
         JobDetailRoute.name,
         args: JobDetailRouteArgs(key: key, job: job),
         initialChildren: children,
       );

  static const String name = 'JobDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<JobDetailRouteArgs>();
      return JobDetailScreen(key: args.key, job: args.job);
    },
  );
}

class JobDetailRouteArgs {
  const JobDetailRouteArgs({this.key, required this.job});

  final Key? key;

  final SampleJob job;

  @override
  String toString() {
    return 'JobDetailRouteArgs{key: $key, job: $job}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JobDetailRouteArgs) return false;
    return key == other.key && job == other.job;
  }

  @override
  int get hashCode => key.hashCode ^ job.hashCode;
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainScreen();
    },
  );
}

/// generated route for
/// [NotificationPreferencesScreen]
class NotificationPreferencesRoute extends PageRouteInfo<void> {
  const NotificationPreferencesRoute({List<PageRouteInfo>? children})
    : super(NotificationPreferencesRoute.name, initialChildren: children);

  static const String name = 'NotificationPreferencesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationPreferencesScreen();
    },
  );
}

/// generated route for
/// [NotificationScreen]
class NotificationRoute extends PageRouteInfo<void> {
  const NotificationRoute({List<PageRouteInfo>? children})
    : super(NotificationRoute.name, initialChildren: children);

  static const String name = 'NotificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationScreen();
    },
  );
}

/// generated route for
/// [OTPScreen]
class OTPRoute extends PageRouteInfo<OTPRouteArgs> {
  OTPRoute({
    Key? key,
    String? twoFactorToken,
    String? phone,
    List<PageRouteInfo>? children,
  }) : super(
         OTPRoute.name,
         args: OTPRouteArgs(
           key: key,
           twoFactorToken: twoFactorToken,
           phone: phone,
         ),
         initialChildren: children,
       );

  static const String name = 'OTPRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OTPRouteArgs>(
        orElse: () => const OTPRouteArgs(),
      );
      return OTPScreen(
        key: args.key,
        twoFactorToken: args.twoFactorToken,
        phone: args.phone,
      );
    },
  );
}

class OTPRouteArgs {
  const OTPRouteArgs({this.key, this.twoFactorToken, this.phone});

  final Key? key;

  final String? twoFactorToken;

  final String? phone;

  @override
  String toString() {
    return 'OTPRouteArgs{key: $key, twoFactorToken: $twoFactorToken, phone: $phone}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OTPRouteArgs) return false;
    return key == other.key &&
        twoFactorToken == other.twoFactorToken &&
        phone == other.phone;
  }

  @override
  int get hashCode => key.hashCode ^ twoFactorToken.hashCode ^ phone.hashCode;
}

/// generated route for
/// [PhoneNumberScreen]
class PhoneNumberRoute extends PageRouteInfo<void> {
  const PhoneNumberRoute({List<PageRouteInfo>? children})
    : super(PhoneNumberRoute.name, initialChildren: children);

  static const String name = 'PhoneNumberRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PhoneNumberScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<ResetPasswordRouteArgs> {
  ResetPasswordRoute({
    Key? key,
    String? sentTo,
    bool viaPhone = false,
    List<PageRouteInfo>? children,
  }) : super(
         ResetPasswordRoute.name,
         args: ResetPasswordRouteArgs(
           key: key,
           sentTo: sentTo,
           viaPhone: viaPhone,
         ),
         initialChildren: children,
       );

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResetPasswordRouteArgs>(
        orElse: () => const ResetPasswordRouteArgs(),
      );
      return ResetPasswordScreen(
        key: args.key,
        sentTo: args.sentTo,
        viaPhone: args.viaPhone,
      );
    },
  );
}

class ResetPasswordRouteArgs {
  const ResetPasswordRouteArgs({this.key, this.sentTo, this.viaPhone = false});

  final Key? key;

  final String? sentTo;

  final bool viaPhone;

  @override
  String toString() {
    return 'ResetPasswordRouteArgs{key: $key, sentTo: $sentTo, viaPhone: $viaPhone}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResetPasswordRouteArgs) return false;
    return key == other.key &&
        sentTo == other.sentTo &&
        viaPhone == other.viaPhone;
  }

  @override
  int get hashCode => key.hashCode ^ sentTo.hashCode ^ viaPhone.hashCode;
}

/// generated route for
/// [ResumeBuilderScreen]
class ResumeBuilderRoute extends PageRouteInfo<void> {
  const ResumeBuilderRoute({List<PageRouteInfo>? children})
    : super(ResumeBuilderRoute.name, initialChildren: children);

  static const String name = 'ResumeBuilderRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ResumeBuilderScreen();
    },
  );
}

/// generated route for
/// [SearchScreen]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchScreen();
    },
  );
}

/// generated route for
/// [SettingScreen]
class SettingRoute extends PageRouteInfo<void> {
  const SettingRoute({List<PageRouteInfo>? children})
    : super(SettingRoute.name, initialChildren: children);

  static const String name = 'SettingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingScreen();
    },
  );
}

/// generated route for
/// [SignupAccountScreen]
class SignupAccountRoute extends PageRouteInfo<void> {
  const SignupAccountRoute({List<PageRouteInfo>? children})
    : super(SignupAccountRoute.name, initialChildren: children);

  static const String name = 'SignupAccountRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignupAccountScreen();
    },
  );
}

/// generated route for
/// [SignupProfileScreen]
class SignupProfileRoute extends PageRouteInfo<void> {
  const SignupProfileRoute({List<PageRouteInfo>? children})
    : super(SignupProfileRoute.name, initialChildren: children);

  static const String name = 'SignupProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignupProfileScreen();
    },
  );
}

/// generated route for
/// [SignupRoleScreen]
class SignupRoleRoute extends PageRouteInfo<void> {
  const SignupRoleRoute({List<PageRouteInfo>? children})
    : super(SignupRoleRoute.name, initialChildren: children);

  static const String name = 'SignupRoleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignupRoleScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [TwoFactorSettingsScreen]
class TwoFactorSettingsRoute extends PageRouteInfo<void> {
  const TwoFactorSettingsRoute({List<PageRouteInfo>? children})
    : super(TwoFactorSettingsRoute.name, initialChildren: children);

  static const String name = 'TwoFactorSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TwoFactorSettingsScreen();
    },
  );
}
