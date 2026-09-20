import 'dart:async';

import 'package:apsaratalent_mobile/core/constants/app_constant.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/common/flow_state.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailVerificationState {
  const EmailVerificationState({
    this.flow = const FlowState.idle(),
    this.resendIn = 0,
    this.verified = false,
  });

  final FlowState flow;

  /// Seconds until another code can be requested. Zero means now.
  final int resendIn;

  final bool verified;

  EmailVerificationState copyWith({
    FlowState? flow,
    int? resendIn,
    bool? verified,
  }) =>
      EmailVerificationState(
        flow: flow ?? this.flow,
        resendIn: resendIn ?? this.resendIn,
        verified: verified ?? this.verified,
      );
}

class EmailVerificationNotifier
    extends AutoDisposeNotifier<EmailVerificationState> {
  Timer? _timer;

  @override
  EmailVerificationState build() {
    ref.onDispose(() => _timer?.cancel());
    return const EmailVerificationState();
  }

  Future<bool> verify(String email, String otp) async {
    final message = await runFlow(
      (s) => state = state.copyWith(flow: s),
      () => ref.read(authRepositoryProvider).verifyEmail(email, otp),
      message: (m) => m,
    );
    if (message == null) return false;
    state = state.copyWith(verified: true);
    // Someone arriving straight from signup is already signed in; their
    // profile now says verified.
    await ref.read(authSessionProvider.notifier).refreshUser();
    return true;
  }

  /// Sends a fresh code and starts the cooldown. The API answers the same way
  /// whether or not the address exists, so this never reveals that either.
  Future<void> resend(String email) async {
    if (state.resendIn > 0 || state.flow.isLoading) return;
    final message = await runFlow(
      (s) => state = state.copyWith(flow: s),
      () => ref.read(authRepositoryProvider).resendEmailOtp(email),
      message: (m) => m,
    );
    if (message != null) _startCooldown();
  }

  /// Codes arrive by email with a delay; the cooldown stops a user hammering
  /// resend into the credential rate limit (five requests a minute).
  void startCooldown() => _startCooldown();

  void _startCooldown() {
    _timer?.cancel();
    state = state.copyWith(resendIn: AppConstants.resendOtpSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.resendIn - 1;
      state = state.copyWith(resendIn: next < 0 ? 0 : next);
      if (next <= 0) timer.cancel();
    });
  }
}

final emailVerificationProvider = NotifierProvider.autoDispose<
    EmailVerificationNotifier, EmailVerificationState>(
  EmailVerificationNotifier.new,
);
