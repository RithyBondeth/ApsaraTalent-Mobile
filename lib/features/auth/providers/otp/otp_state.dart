// OTP state
class OtpState {
  final String otp; // Combined OTP string
  final bool isLoading; // Loading state
  final String? error; // Error message

  OtpState({
    this.otp = '',
    this.isLoading = false,
    this.error,
  });

  bool get isComplete => otp.length == 6;

  OtpState copyWith({
    String? otp,
    bool? isLoading,
    String? error,
    bool clearOtp = false,
    bool clearError = false,
  }) {
    return OtpState(
      otp: clearOtp ? '' : (otp ?? this.otp),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
