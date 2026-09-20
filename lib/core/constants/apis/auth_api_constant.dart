const String apiAuthLogin = '/auth/login';
const String apiAuthLoginOtp = '/auth/login-otp';
const String apiAuthVerifyOtp = '/auth/verify-otp';
const String apiAuthRegisterEmployee = '/auth/register-employee';
const String apiAuthRegisterCompany = '/auth/register-company';
const String apiAuthVerifyEmail = '/auth/verify-email';
const String apiAuthResendEmailOtp = '/auth/verify-email/resend';
const String apiAuthForgotPassword = '/auth/forgot-password';

/// The reset token travels in the path, as the gateway's route declares it.
String apiAuthResetPassword(String token) =>
    '/auth/reset-password/${Uri.encodeComponent(token)}';

const String apiAuthTwoFactorSetup = '/auth/2fa/setup';
const String apiAuthTwoFactorEnable = '/auth/2fa/enable';
const String apiAuthTwoFactorDisable = '/auth/2fa/disable';
const String apiAuthTwoFactorVerifyLogin = '/auth/2fa/verify-login';
const String apiAuthLogout = '/auth/logout';
const String apiCurrentUser = '/user/current-user';
