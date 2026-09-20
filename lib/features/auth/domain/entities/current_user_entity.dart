import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';

/// Who is signed in, reduced to what the app chrome shows: a name, a line under
/// it, and an avatar.
///
/// The API's `/user/current-user` returns the whole employee or company record;
/// the fields that differ by role are flattened here so the header and settings
/// don't need to branch on it.
class CurrentUserEntity {
  const CurrentUserEntity({
    required this.id,
    required this.role,
    required this.displayName,
    this.profileId,
    this.headline,
    this.email,
    this.avatarUrl,
    this.isEmailVerified = true,
    this.isTwoFactorEnabled = false,
  });

  final String id;
  final EUserRole role;

  /// The employee's or company's own id — not [id], which is the user row.
  /// Every profile-scoped endpoint (feed, matching, favourites) takes this.
  final String? profileId;

  /// An employee's full name, or a company's name.
  final String displayName;

  /// An employee's job title, or a company's industry.
  final String? headline;

  final String? email;
  final String? avatarUrl;

  /// False for an email account whose verification code hasn't been entered.
  /// Such an account can use an existing session but cannot sign in again.
  final bool isEmailVerified;

  final bool isTwoFactorEnabled;

  /// A phone-OTP login for a number with no account yet produces a user with
  /// no role and no profile.
  bool get hasAccount => role != EUserRole.none;
}
