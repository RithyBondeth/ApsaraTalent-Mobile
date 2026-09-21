import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/search/domain/entities/job_posting.dart';
import 'package:apsaratalent_mobile/features/search/providers/search_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// One job posting, read by id.
///
/// `/public/job/:jobId` is the only route that reads a single job, and it
/// needs no auth — so this screen takes an id rather than a posting handed
/// down from a list, and works from a deep link as well as from search.
@RoutePage()
class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(jobPostingProvider(jobId));

    return AppScreen(
      appBar: AppBar(title: const Text('Job')),
      children: job.when(
        loading: () => const [_Skeleton()],
        error: (error, _) => [
          PageState(
            variant: PageStateVariant.error,
            title: 'This job could not load',
            description: error is ApiException
                ? error.message
                : 'Check your connection and try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(jobPostingProvider(jobId)),
          ),
        ],
        data: (job) => _content(context, job),
      ),
    );
  }

  List<Widget> _content(BuildContext context, JobPosting job) {
    final t = context.tokens;
    final company = job.company;

    return [
      AppSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(
                  name: company?.name ?? job.title,
                  imageUrl: company?.avatarUrl,
                  size: AppAvatarSize.lg,
                  squared: true,
                ),
                const SizedBox(width: AppShape.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: AppTypography.h4.copyWith(color: t.foreground),
                      ),
                      if (company?.name case final name?) ...[
                        const SizedBox(height: 2),
                        Text(
                          [name, company?.industry]
                              .whereType<String>()
                              .join(' · '),
                          style: AppTypography.small.copyWith(
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
                if (job.workModeLabel case final mode?)
                  MetaChip(icon: LucideIcons.monitor, label: mode),
                if (job.salary case final salary?)
                  MetaChip(icon: LucideIcons.banknote, label: salary),
                if (job.openings case final openings?)
                  MetaChip(
                    icon: LucideIcons.users,
                    label: openings == 1 ? '1 opening' : '$openings openings',
                  ),
              ],
            ),
          ],
        ),
      ),
      if (job.description case final description?) ...[
        const SectionTitle(title: 'About the role'),
        AppSurface(
          child: Text(
            description,
            style: AppTypography.small.copyWith(
              color: t.mutedForeground,
              height: 1.5,
            ),
          ),
        ),
      ],
      if (job.skills.isNotEmpty) ...[
        const SectionTitle(
          title: 'Skills',
          subtitle: 'What this posting asks for',
        ),
        AppSurface(
          child: Wrap(
            spacing: AppShape.space2,
            runSpacing: AppShape.space2,
            children: [for (final skill in job.skills) AppTag(label: skill)],
          ),
        ),
      ],
      if (job.experience != null || job.education != null) ...[
        const SectionTitle(title: 'Requirements'),
        AppSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (job.experience case final experience?)
                _Requirement(
                  icon: LucideIcons.trendingUp,
                  label: 'Experience',
                  value: experience,
                ),
              if (job.education case final education?)
                _Requirement(
                  icon: LucideIcons.graduationCap,
                  label: 'Education',
                  value: education,
                ),
            ],
          ),
        ),
      ],
      const SizedBox(height: AppShape.space2),
      // Applying is POST /job/application, which is not wired yet. Disabled
      // and labelled rather than tapping into nothing.
      const AppButton(
        label: 'Apply',
        icon: LucideIcons.send,
        fullWidth: true,
        onPressed: null,
      ),
      Padding(
        padding: const EdgeInsets.only(top: AppShape.space2),
        child: Text(
          'Applying from the app is not built yet.',
          textAlign: TextAlign.center,
          style: AppTypography.tiny.copyWith(color: t.mutedForeground),
        ),
      ),
      const SizedBox(height: AppShape.space6),
    ];
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: t.mutedForeground),
          const SizedBox(width: AppShape.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.tiny.copyWith(
                    color: t.mutedForeground,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.small.copyWith(color: t.foreground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          AppSurface(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: 56, height: 56),
                SizedBox(width: AppShape.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton(width: 180, height: 20),
                      SizedBox(height: AppShape.space2),
                      AppSkeleton(width: 120, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(height: 12),
                SizedBox(height: AppShape.space2),
                AppSkeleton(height: 12),
                SizedBox(height: AppShape.space2),
                AppSkeleton(width: 200, height: 12),
              ],
            ),
          ),
        ],
      );
}
