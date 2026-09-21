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
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// The viewer's own applications.
///
/// Employee-side only: the pipeline, status changes and notes are company
/// routes, and application history answers an employee with 403.
@RoutePage()
class ApplicationScreen extends ConsumerWidget {
  const ApplicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationsProvider);
    final notifier = ref.read(applicationsProvider.notifier);

    return AppScreen(
      appBar: AppBar(title: const Text('Applications')),
      onRefresh: () async {
        try {
          await notifier.refresh();
        } on ApiException catch (e) {
          if (context.mounted) _snack(context, e.message);
        }
      },
      children: applications.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => [for (var i = 0; i < 3; i++) const _RowSkeleton()],
        error: (error, _) => [
          PageState(
            variant: PageStateVariant.error,
            title: 'Your applications could not load',
            description: error is ApiException
                ? error.message
                : 'Check your connection and try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(applicationsProvider),
          ),
        ],
        data: (state) => _content(context, ref, state),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    WidgetRef ref,
    ApplicationsState state,
  ) =>
      [
        PageBanner(
          eyebrow: 'Applications',
          title: 'Where every application stands',
          subtitle: 'Withdrawing keeps the record; it does not delete it.',
          stats: [
            PageBannerStat(
              icon: LucideIcons.send,
              value: '${state.items.length}',
              label: 'submitted',
            ),
            PageBannerStat(
              icon: LucideIcons.clock,
              value: '${state.open}',
              label: 'still open',
            ),
          ],
        ),
        if (state.items.isEmpty)
          const PageState(
            variant: PageStateVariant.empty,
            icon: LucideIcons.inbox,
            title: 'No applications yet',
            description:
                'Roles you apply for appear here, with where each one stands.',
          )
        else
          for (final application in state.items)
            _ApplicationRow(
              key: ValueKey(application.id),
              application: application,
              busy: state.isPending(application.id),
              onWithdraw: () => _confirmWithdraw(context, ref, application),
            ),
        const SizedBox(height: AppShape.space6),
      ];

  Future<void> _confirmWithdraw(
    BuildContext context,
    WidgetRef ref,
    JobApplication application,
  ) async {
    final role = application.jobTitle ?? 'this role';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw this application?'),
        content: Text(
          'You are telling the company you are no longer interested in '
          '\$role. The application stays in this list, marked withdrawn. '
          'Applying again revives this same application rather than starting '
          'a second one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(applicationsProvider.notifier).withdraw(application);
      if (context.mounted) _snack(context, 'Withdrawn from $role.');
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, e.message);
    }
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({
    super.key,
    required this.application,
    required this.busy,
    required this.onWithdraw,
  });

  final JobApplication application;
  final bool busy;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final status = application.status;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space3),
      child: AppSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // The API's application payload carries jobTitle but
                        // no company, so the role is all this row can name.
                        application.jobTitle ?? 'Role',
                        style: AppTypography.label.copyWith(
                          color: t.foreground,
                          fontSize: AppTypography.base,
                        ),
                      ),
                      if (application.appliedAge.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          application.appliedAge,
                          style: AppTypography.tiny.copyWith(
                            color: t.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppShape.space2),
                AppStatusPill(status: status.tone, label: status.label),
              ],
            ),
            if (status.description.isNotEmpty) ...[
              const SizedBox(height: AppShape.space2),
              Text(
                status.description,
                style: AppTypography.tiny.copyWith(color: t.mutedForeground),
              ),
            ],
            // A rejection reason is the one thing an applicant most wants and
            // rarely gets, so it is shown in full rather than truncated.
            if (application.rejectionReason case final reason?) ...[
              const SizedBox(height: AppShape.space3),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppShape.space3),
                color: t.muted,
                child: Text(
                  reason,
                  style: AppTypography.small.copyWith(
                    color: t.mutedForeground,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            if (status.canWithdraw) ...[
              const SizedBox(height: AppShape.space3),
              Divider(color: t.border, height: AppShape.hairline),
              const SizedBox(height: AppShape.space3),
              AppButton(
                label: 'Withdraw',
                icon: LucideIcons.undo2,
                variant: AppButtonVariant.outline,
                size: AppButtonSize.sm,
                fullWidth: true,
                loading: busy,
                onPressed: busy ? null : onWithdraw,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: AppShape.space3),
        child: AppSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeleton(width: 160, height: 14),
                        SizedBox(height: AppShape.space2),
                        AppSkeleton(width: 90, height: 10),
                      ],
                    ),
                  ),
                  AppSkeleton(width: 70, height: 22),
                ],
              ),
              SizedBox(height: AppShape.space3),
              AppSkeleton(height: 10),
            ],
          ),
        ),
      );
}
