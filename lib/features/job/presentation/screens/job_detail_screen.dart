import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/job_application.dart';
import 'package:apsaratalent_mobile/features/application/providers/application_notifier.dart';
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
        data: (job) => _content(context, ref, job),
      ),
    );
  }

  List<Widget> _content(BuildContext context, WidgetRef ref, JobPosting job) {
    final t = context.tokens;
    final company = job.company;
    // The applications list is already loaded for its own screen, so knowing
    // whether this posting has been applied for costs nothing.
    final applications = ref.watch(applicationsProvider).value;
    final existing = applications?.items
        .where((a) => a.jobId == job.id)
        .cast<JobApplication?>()
        .firstOrNull;
    final active = existing != null && existing.status.isOpen;

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
      AppButton(
        label: active ? 'Applied' : 'Apply',
        icon: active ? LucideIcons.check : LucideIcons.send,
        fullWidth: true,
        // Applying twice answers 409. The button says so rather than letting
        // someone tap into a refusal.
        onPressed: active ? null : () => _apply(context, ref, job),
      ),
      if (existing != null)
        Padding(
          padding: const EdgeInsets.only(top: AppShape.space2),
          child: Text(
            active
                ? '${existing.status.label} · ${existing.appliedAge.toLowerCase()}'
                // A withdrawn application is revived by applying again, not
                // replaced by a second one.
                : 'You withdrew this one. Applying again revives it.',
            textAlign: TextAlign.center,
            style: AppTypography.tiny.copyWith(color: t.mutedForeground),
          ),
        ),
      const SizedBox(height: AppShape.space6),
    ];
  }
}

/// Asks for an optional note, then applies.
///
/// The note is optional because the API treats it so, and a required covering
/// note on a phone would stop people applying rather than improve what they
/// send.
Future<void> _apply(BuildContext context, WidgetRef ref, JobPosting job) async {
  final controller = TextEditingController();
  final send = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: AppShape.screenPadding,
        right: AppShape.screenPadding,
        top: AppShape.screenPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppShape.screenPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apply for ${job.title}',
            style: AppTypography.h4.copyWith(color: context.tokens.foreground),
          ),
          const SizedBox(height: AppShape.space2),
          Text(
            'Add a note if you want to. You can send it without one.',
            style: AppTypography.small.copyWith(
              color: context.tokens.mutedForeground,
            ),
          ),
          const SizedBox(height: AppShape.space4),
          AppInput(
            controller: controller,
            hintText: 'Why you are a fit (optional)',
            maxLines: 4,
          ),
          const SizedBox(height: AppShape.space4),
          AppButton(
            label: 'Send application',
            icon: LucideIcons.send,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppShape.space2),
        ],
      ),
    ),
  );

  final note = controller.text;
  controller.dispose();
  if (send != true || !context.mounted) return;

  try {
    await ref
        .read(applicationsProvider.notifier)
        .apply(job.id, coverLetterNote: note);
    if (!context.mounted) return;
    _snack(context, 'Applied for ${job.title}.');
  } on ApiException catch (e) {
    // A duplicate arrives as the API's own 409 message, which is clearer than
    // anything this screen would write.
    if (context.mounted) _snack(context, e.message);
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
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
