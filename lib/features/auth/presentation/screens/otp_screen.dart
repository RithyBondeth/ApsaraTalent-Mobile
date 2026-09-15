import 'package:apsaratalent_mobile/core/constants/app_constant.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_message.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/otp_field.dart';
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/phone_login/phone_login_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Six-digit code entry for the two sign-in flows that end in a code.
///
/// With a [twoFactorToken] it is the second step of a password sign-in and the
/// code comes from an authenticator app. With a [phone] it is phone sign-in and
/// the code was sent to that number.
@RoutePage()
class OTPScreen extends ConsumerStatefulWidget {
  const OTPScreen({super.key, this.twoFactorToken, this.phone})
      : assert(twoFactorToken != null || phone != null);

  final String? twoFactorToken;
  final String? phone;

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  bool get _isTwoFactor => widget.twoFactorToken != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(otpProvider.notifier).clear(),
    );
  }

  Future<void> _verify() async {
    final code = ref.read(otpProvider);
    if (!code.isComplete) return;

    if (_isTwoFactor) {
      final signedIn = await ref
          .read(otpProvider.notifier)
          .verifyTwoFactor(widget.twoFactorToken!);
      if (signedIn && mounted) context.router.replaceAll([const MainRoute()]);
      return;
    }

    final outcome = await ref
        .read(phoneLoginProvider.notifier)
        .verify(widget.phone!, code.otp);
    if (!mounted) return;
    switch (outcome) {
      case EPhoneLoginOutcome.signedIn:
        context.router.replaceAll([const MainRoute()]);
      case EPhoneLoginOutcome.noAccount:
      case EPhoneLoginOutcome.failed:
        ref.read(otpProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final code = ref.watch(otpProvider);
    final phone = ref.watch(phoneLoginProvider);

    final loading = _isTwoFactor ? code.isLoading : phone.isLoading;
    final error = _isTwoFactor ? code.error : phone.error;
    final noAccount = !_isTwoFactor && (error?.contains('no account') ?? false);

    return AuthScaffold(
      showBack: true,
      showLogo: false,
      title: _isTwoFactor ? 'Two-step verification' : 'Enter the code',
      subtitle: _isTwoFactor
          ? 'Enter the ${AppConstants.otpLength}-digit code from your authenticator app.'
          : 'We sent a ${AppConstants.otpLength}-digit code to ${widget.phone}.',
      children: [
        OtpField(
          length: AppConstants.otpLength,
          // A code is final once typed; submitting on the last digit saves a tap.
          onCompleted: (_) => _verify(),
        ),
        if (error != null) ...[
          const SizedBox(height: AppShape.space4),
          AuthMessage.error(error),
        ],
        const SizedBox(height: AppShape.space5),
        if (noAccount)
          AppButton(
            label: 'Create an account',
            fullWidth: true,
            size: AppButtonSize.lg,
            onPressed: () => context.router.replaceAll([
              const LoginRoute(),
              const SignupRoleRoute(),
            ]),
          )
        else
          AppButton(
            label: 'Verify',
            trailingIcon: LucideIcons.check,
            fullWidth: true,
            size: AppButtonSize.lg,
            loading: loading,
            onPressed: code.isComplete && !loading ? _verify : null,
          ),
        // An authenticator app makes a fresh code every 30 seconds on its own,
        // so only the phone flow has anything to resend.
        if (!_isTwoFactor && !noAccount) ...[
          const SizedBox(height: AppShape.space4),
          Center(
            child: GestureDetector(
              onTap: loading
                  ? null
                  : () {
                      ref.read(otpProvider.notifier).clear();
                      ref.read(phoneLoginProvider.notifier).requestCode(widget.phone!);
                    },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(AppShape.space2),
                child: Text.rich(
                  TextSpan(
                    text: "Didn't receive a code? ",
                    style: AppTypography.small.copyWith(color: t.mutedForeground),
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
