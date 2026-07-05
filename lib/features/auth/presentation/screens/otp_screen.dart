import 'package:apsaratalent_mobile/features/auth/providers/otp_providers.dart';
import 'package:apsaratalent_mobile/core/extensions/color_extensions.dart';
import 'package:apsaratalent_mobile/core/extensions/text_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_button_widget.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_logo_widget.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_otp_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class OTPScreen extends ConsumerWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpCode = ref.watch(combinedOTPProvider);
    final isCompleted = ref.watch(otpCompletedProvider);
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
                    CustomLogoWidget(
                      withoutTitle: true,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Verification Code',
                      style: context.headlineMedium.bold,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Enter the 6-digit code sent to your phone number.',
                      style: context.titleSmall.secondary,
                    )
                  ],
                ),
              ),
              SizedBox(height: 30),
              CustomOTPWidget(
                length: 6,
                onChanged: (value) {
                  // State is managed by Riverpod providers
                  debugPrint('OTP Changed: $value');
                },
                onCompleted: (value) {
                  debugPrint('OTP Completed: $value');
                  // Handle OTP completion
                },
              ),
              TextButton(
                onPressed: () {
                  // Clear OTP and resend code
                  ref.read(clearOTPProvider)();
                  debugPrint('Resend code');
                },
                child: Text(
                  'Didn\'t receive code? Resend',
                  style: context.labelMedium.copyWith(
                    color: context.primary,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomButtonWidget(
                      text: 'Back',
                      icon: Icon(LucideIcons.arrowLeft),
                      iconPosition: IconPosition.before,
                      variant: ButtonVariant.outline,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomButtonWidget(
                      text: 'Verify',
                      icon: Icon(LucideIcons.check),
                      iconPosition: IconPosition.after,
                      onPressed: isCompleted
                          ? () {
                              // Handle verification
                              debugPrint('Verify OTP: $otpCode');
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
