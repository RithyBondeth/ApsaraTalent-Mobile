enum AuthLoginMethod {
  emailPassword('email_password'),
  phoneOtp('phone_otp'),
  google('google'),
  facebook('facebook'),
  linkedin('linkedin'),
  github('github');

  final String value;
  const AuthLoginMethod(this.value);

  factory AuthLoginMethod.fromString(String value) {
    return AuthLoginMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AuthLoginMethod.emailPassword,
    );
  }
}
