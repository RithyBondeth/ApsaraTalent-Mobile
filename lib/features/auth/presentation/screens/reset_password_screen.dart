import 'package:apsaratalent_mobile/shared/extensions/text_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_button_widget.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_input_widget.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_logo_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomLogoWidget(withoutTitle: true),
                    SizedBox(height: 5),
                    Text(
                      'Reset Password',
                      style: context.headlineMedium.bold,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Create a strong password to keep your account safe.',
                      style: context.titleSmall.secondary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  CustomInputWidget(
                    prefixIcon: LucideIcons.key,
                    hintText: 'Token',
                  ),
                  SizedBox(height: 20),
                  CustomInputWidget(
                    prefixIcon: LucideIcons.lock,
                    hintText: 'Password',
                    isPassword: true,
                  ),
                  SizedBox(height: 20),
                  CustomInputWidget(
                    prefixIcon: LucideIcons.lock,
                    hintText: 'Confirm Password',
                    isPassword: true,
                  ),
                ],
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
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
