import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/common/flow_state.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EPhoneLoginOutcome { signedIn, noAccount, failed }

/// Sign in with a phone number and a one-time code.
class PhoneLoginNotifier extends AutoDisposeNotifier<FlowState> {
  @override
  FlowState build() => const FlowState.idle();

  Future<bool> requestCode(String phone) async {
    final result = await runFlow(
      (s) => state = s,
      () => ref.read(authRepositoryProvider).requestPhoneOtp(phone),
      message: (m) => m,
    );
    return result != null;
  }

  Future<EPhoneLoginOutcome> verify(String phone, String otp) async {
    final response = await runFlow(
      (s) => state = s,
      () => ref.read(authRepositoryProvider).verifyPhoneOtp(
            phone,
            otp,
            remember: ref.read(rememberMeProvider),
          ),
    );
    if (response == null) return EPhoneLoginOutcome.failed;

    final session = ref.read(authSessionProvider.notifier);
    await session.establish();

    // The API answers an unknown number by creating a user with no role and
    // signing it in. There is no account behind it, and the API cannot yet turn
    // it into one (registering that phone is refused as a duplicate), so end the
    // session rather than drop the user into an app with no profile.
    final user = ref.read(authSessionProvider).value?.user;
    if (user != null && !user.hasAccount) {
      await session.signOut();
      state = const FlowState(
        error: 'There is no account with this phone number. '
            'Create one with your email address.',
      );
      return EPhoneLoginOutcome.noAccount;
    }
    return EPhoneLoginOutcome.signedIn;
  }
}

final phoneLoginProvider =
    NotifierProvider.autoDispose<PhoneLoginNotifier, FlowState>(
  PhoneLoginNotifier.new,
);
