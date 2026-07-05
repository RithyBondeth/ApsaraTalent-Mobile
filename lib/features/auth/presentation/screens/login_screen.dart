import 'package:apsaratalent_mobile/features/auth/providers/auth_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/auth_validation_providers.dart';
import 'package:apsaratalent_mobile/core/constants/asset_path_constant.dart';
import 'package:apsaratalent_mobile/core/constants/routes_path_contant.dart';
import 'package:apsaratalent_mobile/core/extensions/color_extensions.dart';
import 'package:apsaratalent_mobile/core/extensions/text_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_button_widget.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_input_wideth.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_logo_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailValidationError = ref.watch(emailValidationProvider);
    final passwordValidationError = ref.watch(passwordValidationProvider);
    final isValidLoginForm = ref.watch(loginFormValidProvider);

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomLogoWidget(),
                      Text(
                        'Login to your account',
                        style: context.headlineMedium.bold,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Welcome to Apsara Talent! Select method to log in',
                        style: context.titleSmall.secondary,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  GridView.count(
                    padding: EdgeInsets.all(0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3,
                    children: [
                      _buildSocialButton(
                        context: context,
                        image: AppAssetPathContant.googleIcon,
                        label: 'Google',
                        onClick: () {},
                      ),
                      _buildSocialButton(
                        context: context,
                        image: AppAssetPathContant.facebookIcon,
                        label: 'Facebook',
                        onClick: () {},
                      ),
                      _buildSocialButton(
                        context: context,
                        image: AppAssetPathContant.linkedInIcon,
                        label: 'LinkedIn',
                        onClick: () {},
                      ),
                      _buildSocialButton(
                        context: context,
                        image: AppAssetPathContant.githubIcon,
                        label: 'Github',
                        onClick: () {},
                      ),
                    ],
                  ),
                  _buildPhoneNumberButton(
                    context: context,
                    label: 'Phone Number',
                    onClick: () {
                      context.router.pushPath(
                          AuthRoutesPathConstant.phoneNumberLoginPath);
                    },
                  ),
                  SizedBox(height: 10),
                  _buildDividerBar(context),
                ],
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  CustomInputWidget(
                    prefixIcon: LucideIcons.mail,
                    hintText: 'Email',
                    errorText: emailValidationError,
                    onChanged: (String value) {
                      ref.read(emailInputProvider.notifier).state = value;
                    },
                  ),
                  SizedBox(height: 20),
                  CustomInputWidget(
                    prefixIcon: LucideIcons.key,
                    hintText: 'Password',
                    errorText: passwordValidationError,
                    onChanged: (String value) {
                      ref.read(passwordInputProvider.notifier).state = value;
                    },
                    isPassword: true,
                  ),
                  _buildRememberMeDivider(context, ref),
                  CustomButtonWidget(
                    text: 'Login',
                    onPressed: isValidLoginForm ? () {} : null,
                  ),
                  _buildCreateNewAccountDivider(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String image,
    required String label,
    required VoidCallback onClick,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.primaryForeground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(image, height: 35, width: 35),
          ),
          SizedBox(width: 10),
          Text(label, style: context.titleSmall),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberButton({
    required BuildContext context,
    required String label,
    required VoidCallback onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: context.primaryForeground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.phone),
                SizedBox(width: 10),
                Text(label, style: context.titleSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDividerBar(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Expanded(
              child: Text(
                'or continute with',
                style: context.titleSmall.secondary,
              ),
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildRememberMeDivider(BuildContext context, WidgetRef ref) {
    final rememberMe = ref.watch(rememberMeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: rememberMe,
                  onChanged: (val) {
                    ref.read(rememberMeProvider.notifier).state = val ?? false;
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              Text('Remember Me', style: context.titleSmall.secondary),
            ],
          ),
          InkWell(
            onTap: () {
              context.router
                  .pushPath(AuthRoutesPathConstant.forgotPasswordPath);
            },
            child: Text('Forgot Password?', style: context.titleSmall),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewAccountDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Do not have account yet?',
            style: context.titleSmall.secondary,
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: () {
              context.router.pushPath(AuthRoutesPathConstant.resetPasswordPath);
            },
            child: Text('Create account', style: context.titleSmall),
          ),
        ],
      ),
    );
  }
}
