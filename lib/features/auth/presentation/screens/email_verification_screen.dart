import 'package:apsaratalent_mobile/core/constants/app_constant.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_message.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/otp_field.dart';
import 'package:apsaratalent_mobile/features/auth/providers/email_verification/email_verification_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_notifier.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Confirms an email address with the six-digit code the API sent to it.
///
/// Reached two ways: straight after signup (already signed in, a code just
/// sent), or from a login the API refused because the address was never
/// verified (signed out, and the original code has likely expired — so
/// [sendCode] asks for a fresh one on arrival).
@RoutePage()
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.fromSignup = false,
    this.sendCode = false,
  });

  final String email;
  final bool fromSignup;
  final bool sendCode;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The code boxes share one provider; don't show another screen's digits.
      ref.read(otpProvider.notifier).clear();
      final notifier = ref.read(emailVerificationProvider.notifier);
      if (widget.sendCode) {
        notifier.resend(widget.email);
      } else {
        // A code was sent moments ago by signup itself.
        notifier.startCooldown();
      }
    });
  }

  Future<void> _verify(String code) async {
    final ok = await ref
        .read(emailVerificationProvider.notifier)
        .verify(widget.email, code);
    if (!mounted) return;
    if (!ok) {
      // A wrong code is retyped whole, never edited in place.
      ref.read(otpProvider.notifier).clear();
      return;
    }
    final signedIn = ref.read(authSessionProvider).value?.isAuthenticated ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          signedIn ? 'Email verified. Welcome to Apsara Talent.' : 'Email verified. You can log in now.',
        ),
      ),
    );
    context.router.replaceAll([if (signedIn) const MainRoute() else const LoginRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final state = ref.watch(emailVerificationProvider);
    final code = ref.watch(otpProvider);
    final flow = state.flow;

    return AuthScaffold(
      showBack: !widget.fromSignup,
      showLogo: false,
      title: 'Check your email',
      subtitle:
          'Enter the ${AppConstants.otpLength}-digit code we sent to ${widget.email}.',
      children: [
        OtpField(length: AppConstants.otpLength, onCompleted: _verify),
        const SizedBox(height: AppShape.space4),
        if (flow.error != null)
          AuthMessage.error(flow.error!)
        else if (flow.message != null && !state.verified)
          AuthMessage.info(flow.message!),
        const SizedBox(height: AppShape.space5),
        AppButton(
          label: 'Verify email',
          trailingIcon: LucideIcons.check,
          fullWidth: true,
          size: AppButtonSize.lg,
          loading: flow.isLoading,
          onPressed: code.isComplete && !flow.isLoading ? () => _verify(code.otp) : null,
        ),
        const SizedBox(height: AppShape.space4),
        Center(
          child: state.resendIn > 0
              ? Text(
                  'You can request a new code in ${state.resendIn}s',
                  style: AppTypography.small.copyWith(color: t.mutedForeground),
                )
              : AppButton(
                  label: "Didn't get it? Send a new code",
                  variant: AppButtonVariant.link,
                  onPressed: flow.isLoading
                      ? null
                      : () => ref.read(emailVerificationProvider.notifier).resend(widget.email),
                ),
        ),
        const SizedBox(height: AppShape.space4),
        Text(
          'Codes can take a minute to arrive. Check your spam folder too.',
          textAlign: TextAlign.center,
          style: AppTypography.tiny.copyWith(color: t.mutedForeground, height: 1.5),
        ),
        if (widget.fromSignup) ...[
          const SizedBox(height: AppShape.space5),
          AppButton(
            label: 'Verify later',
            variant: AppButtonVariant.ghost,
            fullWidth: true,
            // The session from signup is valid; only a future *login* needs the
            // address verified. Let people in now and verify later.
            onPressed: () => context.router.replaceAll([const MainRoute()]),
          ),
        ],
      ],
    );
  }
}
