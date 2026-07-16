enum EAuthLoginMethod {
  emailPassword('email_password'),
  phoneOtp('phone_otp'),
  google('google'),
  facebook('facebook'),
  linkedin('linkedin'),
  github('github');

  final String value;
  const EAuthLoginMethod(this.value);

  factory EAuthLoginMethod.fromString(String value) {
    return EAuthLoginMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EAuthLoginMethod.emailPassword,
    );
  }
}
