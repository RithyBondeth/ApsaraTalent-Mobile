import 'package:apsaratalent_mobile/core/constants/app_constant.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/otp_field.dart';
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Six-digit code entry, for two different flows.
///
/// With a [twoFactorToken] this is the second step of a password sign-in: the
/// code comes from the user's authenticator app, and verifying it issues the
/// session. Without one it is the phone-number sign-in's SMS step, which has
/// no endpoint wired yet.
@RoutePage()
class OTPScreen extends ConsumerWidget {
  const OTPScreen({super.key, this.twoFactorToken});

  final String? twoFactorToken;

  bool get _isTwoFactor => twoFactorToken != null;

  Future<void> _verify(BuildContext context, WidgetRef ref) async {
    final token = twoFactorToken;
    if (token == null) return;
    final signedIn = await ref.read(otpProvider.notifier).verifyTwoFactor(token);
    if (signedIn && context.mounted) {
      context.router.replaceAll([const MainRoute()]);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final otpState = ref.watch(otpProvider);

    return AuthScaffold(
      showBack: true,
      showLogo: false,
      title: _isTwoFactor ? 'Two-step verification' : 'Verification code',
      subtitle: _isTwoFactor
          ? 'Enter the ${AppConstants.otpLength}-digit code from your '
              'authenticator app.'
          : 'Enter the ${AppConstants.otpLength}-digit code sent to your '
              'phone number.',
      children: [
        OtpField(
          length: AppConstants.otpLength,
          // An authenticator code is final once typed; submitting on the sixth
          // digit saves a tap. The SMS flow waits for Verify.
          onCompleted: _isTwoFactor ? (_) => _verify(context, ref) : null,
        ),
        if (otpState.error != null) ...[
          const SizedBox(height: AppShape.space3),
          Text(
            otpState.error!,
            style: AppTypography.small.copyWith(color: t.destructive),
          ),
        ],
        const SizedBox(height: AppShape.space5),
        AppButton(
          label: 'Verify',
          trailingIcon: LucideIcons.check,
          fullWidth: true,
          size: AppButtonSize.lg,
          loading: otpState.isLoading,
          // The SMS flow has no verification endpoint wired yet; it enables on
          // a complete code so the screen can be exercised, and deliberately
          // does not log the code.
          onPressed: otpState.isComplete
              ? (_isTwoFactor ? () => _verify(context, ref) : () {})
              : null,
        ),
        // An authenticator app makes a new code every 30 seconds on its own,
        // so there is nothing to resend in the two-factor flow.
        if (!_isTwoFactor) ...[
          const SizedBox(height: AppShape.space4),
          Center(
            child: GestureDetector(
              onTap: () => ref.read(otpProvider.notifier).clear(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(AppShape.space2),
                child: Text.rich(
                  TextSpan(
                    text: "Didn't receive a code? ",
                    style: AppTypography.small.copyWith(
                      color: t.mutedForeground,
                    ),
                    children: [
                      TextSpan(
                        text: 'Resend',
                        style: AppTypography.button.copyWith(color: t.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
