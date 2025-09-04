import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_validation_providers.dart';
import 'package:apsaratalent_mobile/shared/extensions/text_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_button_widget.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_input_wideth.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_logo_widget.dart';
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
    final validationError = ref.watch(forgotPasswordValidationProvider);
    final isFormValid = ref.watch(forgotPasswordFormValidProvider);

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomLogoWidget(
                    withoutTitle: true,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Forgot Password',
                    style: context.headlineMedium.bold,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Enter your Email or Mobile. We will help you reset your password.',
                    style: context.titleSmall.secondary,
                  )
                ],
              ),
              SizedBox(height: 20),
              CustomInputWidget(
                prefixIcon: prefixIcon,
                hintText: 'Email or Phone Number',
                errorText: validationError,
                onChanged: (value) {
                  ref.read(forgotPasswordInputProvider.notifier).state = value;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButtonWidget(
                      text: 'Back',
                      icon: Icon(LucideIcons.arrowLeft),
                      iconPosition: IconPosition.before,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomButtonWidget(
                      text: 'Continue',
                      icon: Icon(LucideIcons.arrowRight),
                      iconPosition: IconPosition.after,
                      onPressed: isFormValid
                          ? () {
                              // Handle form submission
                              final input =
                                  ref.read(forgotPasswordInputProvider);
                              debugPrint('Form submitted with: $input');
                            }
                          : null,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
