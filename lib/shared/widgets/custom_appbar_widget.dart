import 'package:apsaratalent_mobile/shared/extensions/text_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/custom_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomAppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leadingWidth: double.infinity,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: _buildProfileBox(
          context: context,
          title: 'Rithy Bondeth',
          subTitle: 'Software Engineer',
          profile: '',
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Badge(
            label: Text('1'),
            offset: Offset(-5, 5),
            child: IconButton(
              onPressed: () {},
              icon: Icon(LucideIcons.bell),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildProfileBox({
    required BuildContext context,
    required String title,
    required String subTitle,
    required String profile,
  }) {
    return Row(
      children: [
        CustomAvatarWidget(
          imageUrl: profile.isNotEmpty ? profile : null,
          name: title,
          size: AvatarSize.extraLarge,
          borderRadius: AvatarBorderRadius.md,
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: context.titleMedium),
            Text(subTitle, style: context.titleSmall)
          ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
