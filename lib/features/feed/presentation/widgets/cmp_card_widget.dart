import 'package:apsaratalent_mobile/core/extensions/color_extensions.dart';
import 'package:apsaratalent_mobile/core/extensions/text_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CompanyCardWidget extends StatelessWidget {
  const CompanyCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.muted,
          boxShadow: [
            BoxShadow(
              color: context.border.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
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
          ),
        ),
      ),
    );
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
              size: EAvatarSize.veryLarge,
              borderRadius: EAvatarBorderRadius.md,
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
            borderRadius: BorderRadius.circular(8),
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
