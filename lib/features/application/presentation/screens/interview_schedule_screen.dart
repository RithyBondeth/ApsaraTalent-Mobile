import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/employer_workflow.dart';
import 'package:apsaratalent_mobile/features/application/providers/employer_workflow_provider.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class InterviewScheduleScreen extends ConsumerWidget {
  const InterviewScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interviews = ref.watch(employeeInterviewsProvider);
    return AppScreen(
      appBar: AppBar(title: const Text('Interviews')),
      onRefresh: () async {
        ref.invalidate(employeeInterviewsProvider);
        await ref.read(employeeInterviewsProvider.future);
      },
      children: interviews.when(
        loading: () => const [Center(child: CircularProgressIndicator())],
        error: (error, _) => [
          PageState(
            variant: PageStateVariant.error,
            title: 'Your interviews could not load',
            description: error is ApiException
                ? error.message
                : 'Check your connection and try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(employeeInterviewsProvider),
          )
        ],
        data: (items) => [
          PageBanner(
            eyebrow: 'Interview schedule',
            title: 'Your upcoming conversations',
            subtitle:
                'Review the time, location, meeting link, and current response status.',
            stats: [
              PageBannerStat(
                  icon: LucideIcons.calendarDays,
                  value:
                      '${items.where((i) => i.scheduledAt.isAfter(DateTime.now()) && i.status != InterviewStatus.cancelled).length}',
                  label: 'upcoming')
            ],
          ),
          if (items.isEmpty)
            const PageState(
                variant: PageStateVariant.empty,
                icon: LucideIcons.calendarX,
                title: 'No interviews scheduled',
                description: 'New interview invitations will appear here.')
          else
            for (final interview in [
              ...items
            ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt)))
              _InterviewCard(interview: interview),
        ],
      ),
    );
  }
}

class _InterviewCard extends ConsumerStatefulWidget {
  const _InterviewCard({required this.interview});
  final Interview interview;
  @override
  ConsumerState<_InterviewCard> createState() => _InterviewCardState();
}

class _InterviewCardState extends ConsumerState<_InterviewCard> {
  bool _busy = false;
  Future<void> _status(InterviewStatus status) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(employerWorkflowRepositoryProvider)
          .updateInterviewStatus(widget.interview.id, status);
      ref.invalidate(employeeInterviewsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(status == InterviewStatus.accepted
                ? 'Interview accepted.'
                : 'Interview declined.')));
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.interview;
    return AppSurface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(i.title,
              style: AppTypography.label.copyWith(
                  color: context.tokens.foreground,
                  fontSize: AppTypography.base)),
          if (i.companyName case final name?)
            Text(name,
                style: AppTypography.small
                    .copyWith(color: context.tokens.mutedForeground)),
        ])),
        AppStatusPill(status: _tone(i.status), label: _label(i.status)),
      ]),
      const SizedBox(height: AppShape.space3),
      _detail(context, LucideIcons.calendarClock, _dateTime(i.scheduledAt)),
      _detail(context, LucideIcons.timer,
          '${i.durationMinutes} minutes${i.timezone == null ? '' : ' · ${i.timezone}'}'),
      if (i.location case final value?)
        _detail(context, LucideIcons.mapPin, value),
      if (i.description case final value?) ...[
        const SizedBox(height: AppShape.space3),
        Text(value,
            style: AppTypography.small
                .copyWith(color: context.tokens.mutedForeground))
      ],
      if (i.meetingLink case final link?) ...[
        const SizedBox(height: AppShape.space3),
        AppButton(
            label: 'Copy meeting link',
            icon: LucideIcons.copy,
            variant: AppButtonVariant.outline,
            fullWidth: true,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meeting link copied.')));
              }
            }),
      ],
      if (i.status == InterviewStatus.pending) ...[
        const SizedBox(height: AppShape.space3),
        Row(children: [
          Expanded(
              child: AppButton(
                  label: 'Accept',
                  icon: LucideIcons.check,
                  loading: _busy,
                  onPressed:
                      _busy ? null : () => _status(InterviewStatus.accepted))),
          const SizedBox(width: AppShape.space2),
          Expanded(
              child: AppButton(
                  label: 'Decline',
                  icon: LucideIcons.x,
                  variant: AppButtonVariant.outline,
                  onPressed:
                      _busy ? null : () => _status(InterviewStatus.declined))),
        ]),
      ],
    ]));
  }
}

Widget _detail(BuildContext context, IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: AppShape.space2),
    child: Row(children: [
      Icon(icon, size: 16, color: context.tokens.mutedForeground),
      const SizedBox(width: AppShape.space2),
      Expanded(
          child: Text(text,
              style: AppTypography.small
                  .copyWith(color: context.tokens.foreground)))
    ]));
String _dateTime(DateTime value) {
  final d = value.toLocal();
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${m[d.month - 1]} ${d.day}, ${d.year} · $hour:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
}

String _label(InterviewStatus value) => value == InterviewStatus.unknown
    ? 'Unknown'
    : '${value.name[0].toUpperCase()}${value.name.substring(1)}';
AppStatus _tone(InterviewStatus value) => switch (value) {
      InterviewStatus.accepted ||
      InterviewStatus.completed =>
        AppStatus.success,
      InterviewStatus.declined ||
      InterviewStatus.cancelled =>
        AppStatus.destructive,
      InterviewStatus.pending => AppStatus.warning,
      InterviewStatus.unknown => AppStatus.info
    };
