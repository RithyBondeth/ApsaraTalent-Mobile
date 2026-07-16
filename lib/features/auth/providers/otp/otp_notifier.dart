// OTP notifier for managing OTP state
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier() : super(OtpState());

  // Update single digit
  void updateDigit(int index, String digit) {
    final otp = state.otp.split('');
    if (index < otp.length) {
      otp[index] = digit;
    } else {
      otp.add(digit);
    }
    state = state.copyWith(otp: otp.join());
  }

  // Clear all digits
  void clear() {
    state = state.copyWith(clearOtp: true);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) {
  return OtpNotifier();
});
