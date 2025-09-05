import 'package:apsaratalent_mobile/shared/extensions/color_extensions.dart';
import 'package:apsaratalent_mobile/shared/extensions/tailwind_widget_extensions.dart';
import 'package:apsaratalent_mobile/shared/extensions/text_extensions.dart';
import 'package:apsaratalent_mobile/shared/themes/tailwind_styles.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CompanyCardWidget extends StatelessWidget {
  const CompanyCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.muted,
        boxShadow: TW.shadowMd,
        borderRadius: BorderRadius.circular(TW.border2xl),
      ),
      child: Column(
        children: [
          _buildAvatarSection(
            context: context,
            title: 'Quantum Edge',
            subTitle: 'Quantum & Cloud Computing',
            avatarUrl: 'Quantum Edge',
            onLikeTap: () {},
          ),
        ],
      ).p(15),
    ).py(10).px(20);
  }

  Widget _buildAvatarSection({
    required BuildContext context,
    required String title,
    required String subTitle,
    required String avatarUrl,
    required VoidCallback onLikeTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomAvatarWidget(
              name: avatarUrl,
              backgroundColor: context.primary,
              size: AvatarSize.veryLarge,
              borderRadius: AvatarBorderRadius.md,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.titleMedium),
                SizedBox(height: 5),
                Text(subTitle, style: context.labelMedium),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TW.roundedMd),
            color: context.primary,
          ),
          child: IconButton(
            onPressed: onLikeTap,
            icon: Icon(
              LucideIcons.heartHandshake,
              color: context.primaryForeground,
            ),
          ),
        )
      ],
    );
  }
}
