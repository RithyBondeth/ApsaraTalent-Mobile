// OTP notifier for managing OTP state
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/auth/domain/use_cases/verify_two_factor_use_case.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_state.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier(this._ref) : super(OtpState());

  final Ref _ref;

  // Update single digit
  void updateDigit(int index, String digit) {
    final otp = state.otp.split('');
    if (index < otp.length) {
      otp[index] = digit;
    } else {
      otp.add(digit);
    }
    state = state.copyWith(otp: otp.join(), clearError: true);
  }

  // Clear all digits
  void clear() {
    state = state.copyWith(clearOtp: true);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Exchanges [twoFactorToken] and the entered code for a session. Returns
  /// whether the user is now signed in.
  ///
  /// A wrong code clears the boxes: a six-digit code is retyped whole, never
  /// edited in place, and leaving the rejected one up invites resubmitting it.
  Future<bool> verifyTwoFactor(String twoFactorToken) async {
    if (!state.isComplete || state.isLoading) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = _ref.read(authRepositoryProvider);
      await VerifyTwoFactorUseCase(repository)(
        twoFactorToken,
        state.otp,
        remember: _ref.read(rememberMeProvider),
      );
      await _ref.read(authSessionProvider.notifier).establish();
      state = state.copyWith(isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = OtpState(error: e.message);
      return false;
    }
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) {
  return OtpNotifier(ref);
});
