import 'package:apsaratalent_mobile/shared/constants/asset_constant.dart';
import 'package:apsaratalent_mobile/shared/extensions/color_extensions.dart';
import 'package:apsaratalent_mobile/shared/extensions/text_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_input_wideth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      SvgPicture.asset(
                        AppAssetContant.logoForWhiteBg,
                        height: 150,
                      ),
                      Text(
                        'Login to your account',
                        style: context.headlineSmall.bold,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Welcome to Apsara Talent! Select method to log in',
                        style: context.labelMedium.secondary,
                        textAlign: TextAlign.center,
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
                        image: AppAssetContant.googleIcon,
                        label: 'Google',
                        onClick: () {},
                      ),
                      _buildSocialButton(
                        context: context,
                        image: AppAssetContant.facebookIcon,
                        label: 'Facebook',
                        onClick: () {},
                      ),
                      _buildSocialButton(
                        context: context,
                        image: AppAssetContant.linkedInIcon,
                        label: 'LinkedIn',
                        onClick: () {},
                      ),
                      _buildSocialButton(
                        context: context,
                        image: AppAssetContant.githubIcon,
                        label: 'Github',
                        onClick: () {},
                      ),
                    ],
                  ),
                  _buildPhoneNumberButton(
                    context: context,
                    label: 'Phone Number',
                    onClick: () {},
                  ),
                  SizedBox(height: 10),
                  _buildDividerBar(context),
                ],
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  CustomInputWidget(),
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
            child: Image.asset(
              image,
              height: 35,
              width: 35,
            ),
          ),
          SizedBox(width: 10),
          Text(label, style: context.titleMedium),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberButton({
    required BuildContext context,
    required String label,
    required VoidCallback onClick,
  }) {
    return Padding(
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
              Text(label, style: context.titleMedium),
            ],
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
}
