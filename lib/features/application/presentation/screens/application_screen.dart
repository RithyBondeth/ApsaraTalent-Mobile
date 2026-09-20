import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/shared/data/sample_data.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

@RoutePage()
class ApplicationScreen extends ConsumerWidget {
  const ApplicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = SampleData.applications;
    final active = applications
        .where((a) => a.status != AppStatus.destructive)
        .length;

    return AppScreen(
      appBar: AppBar(title: const Text('Applications')),
      children: [
        PageBanner(
          eyebrow: 'Pipeline',
          title: 'Where every application stands',
          subtitle:
              'Stages update when a company moves you forward, so this is the '
              'same view they see.',
          stats: [
            PageBannerStat(
              icon: LucideIcons.send,
              value: '${applications.length}',
              label: 'submitted',
            ),
            PageBannerStat(
              icon: LucideIcons.activity,
              value: '$active',
              label: 'still open',
            ),
          ],
        ),

        if (applications.isEmpty)
          const PageState(
            variant: PageStateVariant.empty,
            icon: LucideIcons.fileX,
            title: 'No applications yet',
            description: 'Roles you apply to are tracked here through to offer.',
          )
        else
          for (final application in applications)
            Padding(
              padding: const EdgeInsets.only(bottom: AppShape.space2),
              child: _ApplicationRow(application: application),
            ),
      ],
    );
  }
}

class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({required this.application});

  final SampleApplication application;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AppSurface(
      onTap: () {},
      elevation: SurfaceElevation.sm,
      padding: const EdgeInsets.all(AppShape.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            name: application.company,
            size: AppAvatarSize.sm,
            squared: true,
          ),
          const SizedBox(width: AppShape.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: t.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  application.company,
                  style: AppTypography.tiny.copyWith(color: t.mutedForeground),
                ),
                const SizedBox(height: AppShape.space2),
                Row(
                  children: [
                    // A pipeline stage genuinely is a state, so this is the
                    // status pill's home ground.
                    AppStatusPill(
                      status: application.status,
                      label: application.stage,
                      dot: true,
                    ),
                    const SizedBox(width: AppShape.space2),
                    Flexible(
                      child: Text(
                        application.updatedAgo,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.tiny.copyWith(
                          color: t.mutedForeground,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
