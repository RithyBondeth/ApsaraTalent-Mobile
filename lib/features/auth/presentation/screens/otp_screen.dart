import 'package:apsaratalent_mobile/core/constants/app_constant.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/otp_field.dart';
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class OTPScreen extends ConsumerWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final otpState = ref.watch(otpProvider);

    return AuthScaffold(
      showBack: true,
      showLogo: false,
      title: 'Verification code',
      subtitle:
          'Enter the ${AppConstants.otpLength}-digit code sent to your phone '
          'number.',
      children: [
        const OtpField(length: AppConstants.otpLength),
        if (otpState.error != null) ...[
          const SizedBox(height: AppShape.space2),
          Text(
            otpState.error!,
            style: AppTypography.tiny.copyWith(color: t.destructive),
          ),
        ],
        const SizedBox(height: AppShape.space5),
        AppButton(
          label: 'Verify',
          trailingIcon: LucideIcons.check,
          fullWidth: true,
          size: AppButtonSize.lg,
          loading: otpState.isLoading,
          // Verification has no endpoint wired yet — OtpNotifier only holds
          // the digits. This enables on a complete code so the flow can be
          // exercised, and deliberately does not log the code it would send.
          onPressed: otpState.isComplete ? () {} : null,
        ),
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
    );
  }
}
