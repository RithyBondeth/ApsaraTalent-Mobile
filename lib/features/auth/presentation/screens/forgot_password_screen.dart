import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_validation_providers.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefixIcon = ref.watch(forgotPasswordPrefixIconProvider);
    final error = ref.watch(forgotPasswordValidationProvider);
    final valid = ref.watch(forgotPasswordFormValidProvider);

    return AuthScaffold(
      showBack: true,
      showLogo: false,
      title: 'Reset your password',
      subtitle:
          'Enter the email or phone number on your account and we will send a '
          'code to confirm it is you.',
      children: [
        AppInput(
          hintText: 'Email or phone number',
          prefixIcon: prefixIcon,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          errorText: error,
          onChanged: (value) =>
              ref.read(forgotPasswordInputProvider.notifier).state = value,
        ),
        const SizedBox(height: AppShape.space5),
        AppButton(
          label: 'Continue',
          trailingIcon: LucideIcons.arrowRight,
          fullWidth: true,
          size: AppButtonSize.lg,
          // Password reset has no endpoint wired yet; the submit is a no-op
          // until it does. It deliberately does not log what was typed — that
          // is an email address or a phone number.
          onPressed: valid ? () {} : null,
        ),
      ],
    );
  }
}
