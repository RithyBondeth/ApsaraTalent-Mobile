import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/shared/extensions/text_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_button_widget.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_input_wideth.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_logo_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class PhoneNumberScreen extends ConsumerWidget {
  const PhoneNumberScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rememberMe = ref.watch(rememberMeProvider);
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
                    'Phone Number',
                    style: context.headlineMedium.bold,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Enter your phone number. We will send you a verification code.',
                    style: context.titleSmall.secondary,
                  )
                ],
              ),
              SizedBox(height: 20),
              CustomInputWidget(
                prefixIcon: LucideIcons.phone,
                hintText: 'Phone Number',
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      value: rememberMe,
                      onChanged: (val) {
                        ref.read(rememberMeProvider.notifier).state =
                            val ?? false;
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  Text('Remember Me', style: context.titleSmall.secondary),
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
                      text: 'Send Code',
                      icon: Icon(LucideIcons.arrowRight),
                      iconPosition: IconPosition.after,
                      onPressed: () {
                        // Handle form submission
                        debugPrint('Send verification code');
                      },
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
