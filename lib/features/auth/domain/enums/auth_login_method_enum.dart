// Auth login method enum
enum EAuthLoginMethod {
  emailPassword('email_password'), // Email + password
  phoneOtp('phone_otp'), // Phone + OTP
  google('google'), // Google login
  facebook('facebook'), // Facebook login
  linkedin('linkedin'), // LinkedIn login
  github('github'); // GitHub login

  final String value;
  const EAuthLoginMethod(this.value);

  // Convert string to enum
  factory EAuthLoginMethod.fromString(String value) {
    return EAuthLoginMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EAuthLoginMethod.emailPassword,
    );
  }
}
