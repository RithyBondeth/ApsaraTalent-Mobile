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
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final viewer = SampleData.viewer;

    return AppScreen(
      appBar: AppBar(title: const Text('Profile')),
      children: [
        // Identity Section
        AppSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(name: viewer.name, size: AppAvatarSize.xl),
                  const SizedBox(width: AppShape.space4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewer.name,
                          style: AppTypography.h4.copyWith(
                            color: t.foreground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          viewer.headline,
                          style: AppTypography.small.copyWith(
                            color: t.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: AppShape.space2),
                        MetaChip(
                          icon: LucideIcons.mapPin,
                          label: viewer.location,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppShape.space3),
              // Availability is categorical — a kind of arrangement, not a
              // severity. It must never render as a status pill.
              AppCategoryChip(
                category: viewer.availability.category,
                label: viewer.availability.label,
                icon: LucideIcons.circleDot,
              ),
            ],
          ),
        ),

        // Completion Section
        _CompletionCard(completion: viewer.completion),

        const SectionTitle(
          title: 'Skills',
          subtitle: 'What matching is ranked against',
        ),
        AppSurface(
          child: Wrap(
            spacing: AppShape.space2,
            runSpacing: AppShape.space2,
            children: [
              for (final skill in viewer.skills) AppTag(label: skill),
            ],
          ),
        ),

        const SectionTitle(title: 'Languages'),
        AppSurface(
          child: Wrap(
            spacing: AppShape.space2,
            runSpacing: AppShape.space2,
            children: [
              for (final language in viewer.languages)
                AppTag(label: language, icon: LucideIcons.languages),
            ],
          ),
        ),

        const SizedBox(height: AppShape.space2),
        AppButton(
          label: 'Edit profile',
          icon: LucideIcons.pencil,
          fullWidth: true,
          onPressed: () {},
        ),
        const SizedBox(height: AppShape.space6),
      ],
    );
  }
}

/// How complete the profile is.
///
/// The bar is `primary` on `muted` rather than running green-to-red across the
/// range: completeness is a quantity, not a severity, and colouring a
/// half-filled profile amber would put it in the same visual language as a
/// failed application.
class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.completion});

  final double completion;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final percent = (completion * 100).round();

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Profile completion',
                  style: AppTypography.label.copyWith(color: t.foreground),
                ),
              ),
              Text(
                '$percent%',
                style: AppTypography.statValue.copyWith(
                  color: t.foreground,
                  fontSize: AppTypography.xl,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppShape.space3),
          Stack(
            children: [
              Container(height: 8, color: t.muted),
              FractionallySizedBox(
                widthFactor: completion.clamp(0, 1),
                child: Container(height: 8, color: t.primary),
              ),
            ],
          ),
          const SizedBox(height: AppShape.space3),
          Text(
            'Add a work history and a portfolio link to reach 100%.',
            style: AppTypography.tiny.copyWith(
              color: t.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
