class SocialAuthResult {
  const SocialAuthResult.authenticated()
      : newUser = false,
        profile = null;
  const SocialAuthResult.newUser(this.profile) : newUser = true;

  final bool newUser;
  final SocialAuthProfile? profile;
}

class SocialAuthProfile {
  const SocialAuthProfile({
    required this.provider,
    this.email,
    this.firstName,
    this.lastName,
    this.picture,
  });

  final String provider;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? picture;
}
