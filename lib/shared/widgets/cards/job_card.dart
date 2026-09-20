import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/search/domain/entities/job_posting.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// One job posting in a list.
///
/// Skills are neutral tags; nothing on the card is coloured. Employment type
/// and work mode are meta, not status — a full-time role is not a state of
/// health.
class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, this.onTap});

  final JobPosting job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final company = job.company;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space3),
      child: AppSurface(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(
                  name: company?.name ?? job.title,
                  imageUrl: company?.avatarUrl,
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
                          fontSize: AppTypography.base,
                        ),
                      ),
                      if (company?.name case final name?) ...[
                        const SizedBox(height: 2),
                        Text(
                          name,
                          style: AppTypography.tiny.copyWith(
                            color: t.mutedForeground,
                          ),
                        ),
                      ],
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
                if (job.where case final where?)
                  MetaChip(icon: LucideIcons.mapPin, label: where),
                if (job.typeLabel case final type?)
                  MetaChip(icon: LucideIcons.briefcase, label: type),
                if (job.salary case final salary?)
                  MetaChip(icon: LucideIcons.banknote, label: salary),
              ],
            ),
            if (job.skills.isNotEmpty) ...[
              const SizedBox(height: AppShape.space3),
              Wrap(
                spacing: AppShape.space2,
                runSpacing: AppShape.space2,
                children: [
                  for (final skill in job.skills.take(5)) AppTag(label: skill),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
