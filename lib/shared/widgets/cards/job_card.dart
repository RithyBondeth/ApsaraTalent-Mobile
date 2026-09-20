import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/shared/data/sample_data.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_avatar.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_surface.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_tag.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/section_title.dart';
import 'package:apsaratalent_mobile/shared/widgets/cards/match_meter.dart';

/// A job posting in a list.
///
/// The skill chips are [AppTag]s — neutral, because a skill name is not a state
/// and not a kind. The employment type is the one coloured label here, and it
/// is categorical rather than a status.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onSave,
    this.saved = false,
  });

  final SampleJob job;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final bool saved;

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
                name: job.company,
                size: AppAvatarSize.md,
                squared: true,
              ),
              const SizedBox(width: AppShape.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        color: t.foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: AppTypography.base,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.tiny.copyWith(
                        color: t.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onSave,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppShape.space2),
                  child: Icon(
                    saved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
                    size: 18,
                    color: saved ? t.primary : t.mutedForeground,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppShape.space3),
          Wrap(
            spacing: AppShape.space4,
            runSpacing: AppShape.space2,
            children: [
              MetaChip(icon: LucideIcons.mapPin, label: job.location),
              MetaChip(icon: LucideIcons.briefcase, label: job.employmentType),
              MetaChip(icon: LucideIcons.clock, label: job.postedAgo),
            ],
          ),

          const SizedBox(height: AppShape.space3),
          Wrap(
            spacing: AppShape.space2,
            runSpacing: AppShape.space2,
            children: [for (final skill in job.skills) AppTag(label: skill)],
          ),

          const SizedBox(height: AppShape.space3),
          Divider(color: t.border, height: AppShape.hairline),
          const SizedBox(height: AppShape.space3),
          MatchMeter(score: job.matchScore),
        ],
      ),
    );
  }
}
