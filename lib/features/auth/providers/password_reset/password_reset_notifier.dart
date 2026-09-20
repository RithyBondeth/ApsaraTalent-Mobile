import 'package:apsaratalent_mobile/core/validators/identifier_validator.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/common/flow_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Forgot password, then reset.
///
/// The API sends the reset token as text — in an email, or an SMS for a
/// phone-only account — not as a link, so the reset screen takes the token as
/// input rather than expecting the app to be opened from a URL.
class PasswordResetNotifier extends AutoDisposeNotifier<FlowState> {
  @override
  FlowState build() => const FlowState.idle();

  /// Returns whether the API accepted the request.
  Future<bool> request(String identifier) async {
    final result = await runFlow(
      (s) => state = s,
      () => ref
          .read(authRepositoryProvider)
          .forgotPassword(IdentifierValidator.normalize(identifier)),
      message: (m) => m,
    );
    return result != null;
  }

  Future<bool> reset({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final result = await runFlow(
      (s) => state = s,
      () => ref.read(authRepositoryProvider).resetPassword(
            token: normalizeResetToken(token),
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          ),
      message: (m) => m,
    );
    return result != null;
  }

  void clear() => state = const FlowState.idle();
}

final passwordResetProvider =
    NotifierProvider.autoDispose<PasswordResetNotifier, FlowState>(
  PasswordResetNotifier.new,
);

/// Tokens are copied out of an email whose sentence ends right after them
/// ("…your reset password token: 3f9c….") and from SMS, so a paste drags in
/// whitespace and the full stop. The API's tokens are hex, so nothing a real
/// token contains is lost by keeping only letters and digits.
String normalizeResetToken(String raw) =>
    raw.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
