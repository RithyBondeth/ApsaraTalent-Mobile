import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/validators/identifier_validator.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_message.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_validation_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/password_reset/password_reset_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final identifier = ref.read(forgotPasswordInputProvider);
    final sent = await ref.read(passwordResetProvider.notifier).request(identifier);
    if (sent && context.mounted) {
      context.router.push(
        ResetPasswordRoute(
          sentTo: IdentifierValidator.normalize(identifier),
          viaPhone: IdentifierValidator.kindOf(identifier) == EIdentifierKind.phone,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefixIcon = ref.watch(forgotPasswordPrefixIconProvider);
    final error = ref.watch(forgotPasswordValidationProvider);
    final valid = ref.watch(forgotPasswordFormValidProvider);
    final flow = ref.watch(passwordResetProvider);

    return AuthScaffold(
      showBack: true,
      showLogo: false,
      title: 'Reset your password',
      subtitle:
          'Enter the email or phone number on your account and we will send a '
          'reset token to it.',
      children: [
        AppInput(
          hintText: 'Email or phone number',
          prefixIcon: prefixIcon,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          errorText: error,
          onChanged: (value) {
            ref.read(forgotPasswordInputProvider.notifier).state = value;
            if (flow.error != null) ref.read(passwordResetProvider.notifier).clear();
          },
          onSubmitted: (_) {
            if (valid && !flow.isLoading) _submit(context, ref);
          },
        ),
        if (flow.error != null) ...[
          const SizedBox(height: AppShape.space4),
          AuthMessage.error(flow.error!),
        ],
        const SizedBox(height: AppShape.space5),
        AppButton(
          label: 'Send reset token',
          trailingIcon: LucideIcons.arrowRight,
          fullWidth: true,
          size: AppButtonSize.lg,
          loading: flow.isLoading,
          onPressed: valid ? () => _submit(context, ref) : null,
        ),
        const SizedBox(height: AppShape.space4),
        AppButton(
          label: 'I already have a token',
          variant: AppButtonVariant.link,
          fullWidth: true,
          onPressed: () => context.router.push(ResetPasswordRoute()),
        ),
      ],
    );
  }
}
