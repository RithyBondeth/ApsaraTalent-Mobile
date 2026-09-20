import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/shared/data/sample_data.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_avatar.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_status_pill.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_surface.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/section_title.dart';
import 'package:apsaratalent_mobile/shared/widgets/cards/match_meter.dart';

/// A company in the feed.
///
/// Benefits are the one place a categorical hue is spent on this card: they are
/// a *kind* of thing, and pink is the slot the web app assigns them. Everything
/// else — industry, size, location — is neutral metadata.
class CompanyCard extends StatelessWidget {
  const CompanyCard({
    super.key,
    required this.company,
    this.onTap,
    this.onFollow,
    this.following = false,
  });

  final SampleCompany company;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;
  final bool following;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AppSurface(
      onTap: onTap,
      elevation: SurfaceElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(
                name: company.name,
                size: AppAvatarSize.lg,
                squared: true,
              ),
              const SizedBox(width: AppShape.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        color: t.foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: AppTypography.base,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      company.industry,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.tiny.copyWith(
                        color: t.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: AppShape.space2),
                    Wrap(
                      spacing: AppShape.space3,
                      runSpacing: AppShape.space1,
                      children: [
                        MetaChip(
                          icon: LucideIcons.mapPin,
                          label: company.location,
                        ),
                        MetaChip(
                          icon: LucideIcons.users,
                          label: '${company.size} people',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppShape.space3),
          Wrap(
            spacing: AppShape.space2,
            runSpacing: AppShape.space2,
            children: [
              for (final benefit in company.benefits)
                AppCategoryChip(
                  category: AppCategory.pink,
                  label: benefit,
                ),
            ],
          ),

          const SizedBox(height: AppShape.space3),
          Divider(color: t.border, height: AppShape.hairline),
          const SizedBox(height: AppShape.space3),
          Row(
            children: [
              Expanded(child: MatchMeter(score: company.matchScore)),
              Text(
                '${company.openRoles} open roles',
                style: AppTypography.tiny.copyWith(
                  color: t.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
