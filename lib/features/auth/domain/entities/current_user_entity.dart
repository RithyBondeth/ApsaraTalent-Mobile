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
    this.headline,
    this.email,
    this.avatarUrl,
  });

  final String id;
  final EUserRole role;

  /// An employee's full name, or a company's name.
  final String displayName;

  /// An employee's job title, or a company's industry.
  final String? headline;

  final String? email;
  final String? avatarUrl;
}
