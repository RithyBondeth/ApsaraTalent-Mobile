import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/employer_workflow.dart';
import 'package:apsaratalent_mobile/features/application/domain/entities/job_application.dart';
import 'package:apsaratalent_mobile/features/application/providers/employer_workflow_provider.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

class EmployerWorkflowScreen extends ConsumerStatefulWidget {
  const EmployerWorkflowScreen({super.key, required this.profile});

  final CompanyProfile profile;

  @override
  ConsumerState<EmployerWorkflowScreen> createState() =>
      _EmployerWorkflowScreenState();
}

class _EmployerWorkflowScreenState
    extends ConsumerState<EmployerWorkflowScreen> {
  String? _jobId;
  final _selected = <String>{};
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final jobs = widget.profile.openPositionItems;
    final selectedJob = jobs.isEmpty
        ? null
        : jobs.firstWhere(
            (job) => job.id == _jobId,
            orElse: () => jobs.first,
          );
    final analytics = ref.watch(employerAnalyticsProvider);
    final interviews = ref.watch(employerInterviewsProvider);
    final pipeline = selectedJob == null
        ? null
        : ref.watch(jobPipelineProvider((
            jobId: selectedJob.id,
            companyId: widget.profile.id,
          )));

    return AppScreen(
      appBar: AppBar(title: const Text('Hiring workflow')),
      onRefresh: () async {
        ref.invalidate(employerAnalyticsProvider);
        ref.invalidate(employerInterviewsProvider);
        if (selectedJob != null) {
          ref.invalidate(jobPipelineProvider((
            jobId: selectedJob.id,
            companyId: widget.profile.id,
          )));
        }
      },
      children: [
        _analytics(analytics),
        const SectionTitle(
          title: 'Applicant pipeline',
          subtitle: 'Move applicants through each hiring stage',
        ),
        if (jobs.isEmpty)
          const PageState(
            variant: PageStateVariant.empty,
            icon: LucideIcons.briefcase,
            title: 'No open positions',
            description:
                'Post a role before managing applicants and interviews.',
          )
        else ...[
          AppPickerField(
            labelText: 'Position',
            hintText: 'Choose a position',
            value: selectedJob?.title,
            onTap: () => _pickJob(jobs, selectedJob!),
          ),
          const SizedBox(height: AppShape.space3),
          if (_selected.isNotEmpty) _bulkBar(selectedJob!),
          ...pipeline!.when(
            loading: () => [for (var i = 0; i < 3; i++) const _Skeleton()],
            error: (error, _) => [
              PageState(
                variant: PageStateVariant.error,
                title: 'The applicant pipeline could not load',
                description: _message(error),
                actionLabel: 'Try again',
                onAction: () => ref.invalidate(jobPipelineProvider((
                  jobId: selectedJob!.id,
                  companyId: widget.profile.id,
                ))),
              ),
            ],
            data: (value) => _pipeline(value, selectedJob!),
          ),
        ],
        const SectionTitle(
          title: 'Interviews',
          subtitle: 'Upcoming and completed interviews',
        ),
        ...interviews.when(
          loading: () => [const _Skeleton()],
          error: (error, _) => [
            PageState(
              variant: PageStateVariant.error,
              title: 'Interviews could not load',
              description: _message(error),
              actionLabel: 'Try again',
              onAction: () => ref.invalidate(employerInterviewsProvider),
            ),
          ],
          data: _interviews,
        ),
        const SizedBox(height: AppShape.space6),
      ],
    );
  }

  Widget _analytics(AsyncValue<EmployerAnalytics> value) => value.when(
        loading: () => const _Skeleton(),
        error: (_, __) => const SizedBox.shrink(),
        data: (analytics) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageBanner(
              eyebrow: 'Employer analytics',
              title: 'Hiring at a glance',
              subtitle: analytics.medianDaysToFirstMove == null
                  ? 'Move an applicant to start measuring response time.'
                  : 'Median first response: '
                      '${analytics.medianDaysToFirstMove!.toStringAsFixed(1)} days · '
                      '${analytics.applicationsCurrent} applications this month '
                      '(${analytics.applicationsDelta >= 0 ? '+' : ''}${analytics.applicationsDelta})',
              stats: [
                PageBannerStat(
                  icon: LucideIcons.briefcase,
                  value: '${analytics.openPositions}',
                  label: 'open roles',
                ),
                PageBannerStat(
                  icon: LucideIcons.users,
                  value: '${analytics.activePipeline}',
                  label: 'active',
                ),
                PageBannerStat(
                  icon: LucideIcons.userCheck,
                  value: '${analytics.hired30d}',
                  label: 'hired 30d',
                ),
              ],
            ),
            if (analytics.funnel.isNotEmpty)
              AppSurface(
                child: Wrap(
                  spacing: AppShape.space3,
                  runSpacing: AppShape.space2,
                  children: [
                    for (final stage in analytics.funnel)
                      AppStatusPill(
                        status: stage.status.tone,
                        label: '${stage.status.label} ${stage.count}',
                      ),
                  ],
                ),
              ),
            if (analytics.topJobs.isNotEmpty) ...[
              const SectionTitle(title: 'Top positions'),
              AppSurface(
                child: Column(
                  children: [
                    for (final job in analytics.topJobs)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(job.title),
                        subtitle: Text(
                          '${job.activePipeline} active · ${job.hired} hired · '
                          '${job.rejected} rejected',
                        ),
                        trailing: Text('${job.totalApplicants}'),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  List<Widget> _pipeline(JobPipeline pipeline, ProfileJob job) => [
        if (pipeline.totalCount == 0)
          const PageState(
            variant: PageStateVariant.empty,
            icon: LucideIcons.inbox,
            title: 'No applicants for this role',
            description: 'New applications will appear here automatically.',
          )
        else
          for (final column in pipeline.columns) ...[
            SectionTitle(
              title: column.status.label,
              subtitle:
                  '${column.count} applicant${column.count == 1 ? '' : 's'}',
            ),
            for (final application in column.applications)
              _applicant(application, job),
          ],
      ];

  Widget _applicant(JobApplication application, ProfileJob job) {
    final selected = _selected.contains(application.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space3),
      child: AppSurface(
        borderColor: selected ? context.tokens.primary : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: _busy
                      ? null
                      : (value) => setState(() => value == true
                          ? _selected.add(application.id)
                          : _selected.remove(application.id)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.employeeName ?? 'Applicant',
                        style: AppTypography.label,
                      ),
                      Text(application.appliedAge),
                    ],
                  ),
                ),
                if (application.matchScore case final score?)
                  AppStatusPill(
                    status: score >= 70 ? AppStatus.success : AppStatus.info,
                    label: '${score.round()}% fit',
                  ),
              ],
            ),
            if (application.coverLetterNote case final note?) ...[
              const SizedBox(height: AppShape.space2),
              Text(note, maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: AppShape.space3),
            Wrap(
              spacing: AppShape.space2,
              runSpacing: AppShape.space2,
              children: [
                AppButton(
                  label: 'Details',
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.outline,
                  onPressed: () => _showApplicant(application, job),
                ),
                if (_nextStatuses(application.status).isNotEmpty)
                  AppButton(
                    label: 'Move stage',
                    size: AppButtonSize.sm,
                    onPressed: _busy ? null : () => _moveOne(application, job),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulkBar(ProfileJob job) => Padding(
        padding: const EdgeInsets.only(bottom: AppShape.space3),
        child: AppSurface(
          accent: SurfaceAccent.info,
          child: Row(
            children: [
              Expanded(child: Text('${_selected.length} selected')),
              AppButton(
                label: 'Move',
                size: AppButtonSize.sm,
                loading: _busy,
                onPressed: _busy ? null : () => _bulkMove(job),
              ),
              AppButton.icon(
                icon: LucideIcons.x,
                semanticLabel: 'Clear selection',
                onPressed: _busy ? null : () => setState(_selected.clear),
              ),
            ],
          ),
        ),
      );

  List<Widget> _interviews(List<Interview> interviews) {
    if (interviews.isEmpty) {
      return const [
        PageState(
          variant: PageStateVariant.empty,
          icon: LucideIcons.calendar,
          title: 'No interviews scheduled',
          description: 'Schedule one from an applicant’s details.',
        ),
      ];
    }
    return [
      for (final interview in interviews)
        Padding(
          padding: const EdgeInsets.only(bottom: AppShape.space3),
          child: AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(interview.title, style: AppTypography.label),
                Text(
                  '${interview.employeeName ?? 'Applicant'} · '
                  '${_dateTime(interview.scheduledAt)}',
                ),
                if (interview.location != null) Text(interview.location!),
                const SizedBox(height: AppShape.space2),
                AppStatusPill(
                  status: _interviewTone(interview.status),
                  label: interview.status.name,
                ),
                if (interview.status == InterviewStatus.pending ||
                    interview.status == InterviewStatus.accepted) ...[
                  const SizedBox(height: AppShape.space3),
                  Wrap(
                    spacing: AppShape.space2,
                    children: [
                      if (interview.status == InterviewStatus.accepted)
                        AppButton(
                          label: 'Complete',
                          size: AppButtonSize.sm,
                          onPressed: _busy
                              ? null
                              : () => _setInterview(
                                  interview, InterviewStatus.completed),
                        ),
                      AppButton(
                        label: 'Cancel',
                        size: AppButtonSize.sm,
                        variant: AppButtonVariant.destructive,
                        onPressed: _busy
                            ? null
                            : () => _setInterview(
                                interview, InterviewStatus.cancelled),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
    ];
  }

  Future<void> _pickJob(List<ProfileJob> jobs, ProfileJob selected) async {
    final picked = await showPickerSheet<String>(
      context,
      title: 'Position',
      items: [for (final job in jobs) PickerItem(job.title, job.id)],
      selected: selected.id,
    );
    if (picked != null) {
      setState(() {
        _jobId = picked;
        _selected.clear();
      });
    }
  }

  Future<void> _moveOne(JobApplication application, ProfileJob job) async {
    final statuses = _nextStatuses(application.status);
    final status = await showPickerSheet<ApplicationStatus>(
      context,
      title: 'Move applicant',
      items: [for (final value in statuses) PickerItem(value.label, value)],
    );
    if (status == null) return;
    final reason = status == ApplicationStatus.rejected
        ? await _textPrompt('Rejection reason', required: false)
        : null;
    await _run(() => ref
        .read(employerWorkflowRepositoryProvider)
        .updateStatus(application.id, status, rejectionReason: reason));
    _refreshPipeline(job);
  }

  Future<void> _bulkMove(ProfileJob job) async {
    const statuses = [
      ApplicationStatus.shortlisted,
      ApplicationStatus.interviewing,
      ApplicationStatus.offered,
      ApplicationStatus.hired,
      ApplicationStatus.rejected,
    ];
    final status = await showPickerSheet<ApplicationStatus>(
      context,
      title: 'Move selected applicants',
      items: [for (final value in statuses) PickerItem(value.label, value)],
    );
    if (status == null) return;
    final reason = status == ApplicationStatus.rejected
        ? await _textPrompt('Rejection reason', required: false)
        : null;
    BulkUpdateResult? result;
    await _run(() async {
      result = await ref.read(employerWorkflowRepositoryProvider).bulkUpdate(
            _selected.toList(),
            status,
            rejectionReason: reason,
          );
    });
    if (!mounted || result == null) return;
    _snack(
        '${result!.updated} updated${result!.failed > 0 ? ', ${result!.failed} failed' : ''}.');
    setState(_selected.clear);
    _refreshPipeline(job);
  }

  Future<void> _showApplicant(
      JobApplication application, ProfileJob job) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ApplicantDetails(
        application: application,
        job: job,
        companyId: widget.profile.id,
      ),
    );
    _refreshPipeline(job);
    ref.invalidate(employerInterviewsProvider);
  }

  Future<void> _setInterview(
      Interview interview, InterviewStatus status) async {
    await _run(() => ref
        .read(employerWorkflowRepositoryProvider)
        .updateInterviewStatus(interview.id, status));
    ref.invalidate(employerInterviewsProvider);
  }

  Future<void> _run(Future<void> Function() work) async {
    setState(() => _busy = true);
    try {
      await work();
    } on ApiException catch (error) {
      if (mounted) _snack(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _refreshPipeline(ProfileJob job) => ref.invalidate(jobPipelineProvider((
        jobId: job.id,
        companyId: widget.profile.id,
      )));

  Future<String?> _textPrompt(String title, {required bool required}) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration:
              InputDecoration(hintText: required ? 'Required' : 'Optional'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (!required || controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  String _message(Object error) => error is ApiException
      ? error.message
      : 'Check your connection and try again.';

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ApplicantDetails extends ConsumerStatefulWidget {
  const _ApplicantDetails({
    required this.application,
    required this.job,
    required this.companyId,
  });
  final JobApplication application;
  final ProfileJob job;
  final String companyId;

  @override
  ConsumerState<_ApplicantDetails> createState() => _ApplicantDetailsState();
}

class _ApplicantDetailsState extends ConsumerState<_ApplicantDetails> {
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(applicationNotesProvider(widget.application.id));
    final history =
        ref.watch(applicationHistoryProvider(widget.application.id));
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .88,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(AppShape.space4),
          children: [
            Text(widget.application.employeeName ?? 'Applicant',
                style: Theme.of(context).textTheme.headlineSmall),
            Text(widget.job.title),
            if (widget.application.coverLetterNote case final note?) ...[
              const SectionTitle(title: 'Cover note'),
              AppSurface(child: Text(note)),
            ],
            const SizedBox(height: AppShape.space3),
            AppButton(
              label: 'Schedule interview',
              icon: LucideIcons.calendarPlus,
              fullWidth: true,
              onPressed: _busy ? null : _schedule,
            ),
            const SectionTitle(title: 'Private notes'),
            AppInput(
              controller: _note,
              hintText: 'Add a private hiring note',
              maxLines: 3,
            ),
            const SizedBox(height: AppShape.space2),
            AppButton(
              label: 'Add note',
              size: AppButtonSize.sm,
              loading: _busy,
              onPressed: _busy ? null : _addNote,
            ),
            ...notes.when(
              loading: () => [const LinearProgressIndicator()],
              error: (_, __) => [const Text('Notes could not load.')],
              data: (items) => [
                for (final note in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(note.body),
                    subtitle: Text(note.authorName ?? 'Company'),
                    trailing: IconButton(
                      tooltip: 'Delete note',
                      onPressed: _busy ? null : () => _deleteNote(note),
                      icon: const Icon(LucideIcons.trash2),
                    ),
                  ),
              ],
            ),
            const SectionTitle(title: 'Status history'),
            ...history.when(
              loading: () => [const LinearProgressIndicator()],
              error: (_, __) => [const Text('History could not load.')],
              data: (items) => items.isEmpty
                  ? [const Text('No stage changes yet.')]
                  : [
                      for (final item in items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(LucideIcons.history),
                          title: Text(
                            '${item.from?.label ?? 'Applied'} → ${item.to.label}',
                          ),
                          subtitle: Text(item.actorName ?? 'System'),
                        ),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addNote() async {
    final body = _note.text.trim();
    if (body.isEmpty) return;
    await _run(() => ref
        .read(employerWorkflowRepositoryProvider)
        .addNote(widget.application.id, body));
    _note.clear();
    ref.invalidate(applicationNotesProvider(widget.application.id));
  }

  Future<void> _deleteNote(ApplicationNote note) async {
    await _run(() => ref
        .read(employerWorkflowRepositoryProvider)
        .deleteNote(widget.application.id, note.id));
    ref.invalidate(applicationNotesProvider(widget.application.id));
  }

  Future<void> _schedule() async {
    if (widget.application.employeeId == null) return;
    final title =
        TextEditingController(text: 'Interview — ${widget.job.title}');
    final location = TextEditingController();
    final link = TextEditingController();
    var scheduled = DateTime.now().add(const Duration(days: 1));
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Schedule interview'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title')),
                TextField(
                    controller: location,
                    decoration: const InputDecoration(labelText: 'Location')),
                TextField(
                    controller: link,
                    decoration:
                        const InputDecoration(labelText: 'Meeting link')),
                const SizedBox(height: AppShape.space3),
                TextButton.icon(
                  icon: const Icon(LucideIcons.calendar),
                  label: Text(_dateTime(scheduled)),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                      initialDate: scheduled,
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(scheduled),
                    );
                    if (time != null) {
                      setDialogState(() => scheduled = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          ));
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Schedule')),
          ],
        ),
      ),
    );
    if (accepted == true && title.text.trim().isNotEmpty) {
      await _run(
          () => ref.read(employerWorkflowRepositoryProvider).createInterview(
                employeeId: widget.application.employeeId!,
                companyId: widget.companyId,
                applicationId: widget.application.id,
                title: title.text,
                scheduledAt: scheduled,
                durationMinutes: 60,
                location: location.text,
                meetingLink: link.text,
              ));
    }
    title.dispose();
    location.dispose();
    link.dispose();
  }

  Future<void> _run(Future<void> Function() work) async {
    setState(() => _busy = true);
    try {
      await work();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

List<ApplicationStatus> _nextStatuses(ApplicationStatus status) =>
    switch (status) {
      ApplicationStatus.pending || ApplicationStatus.reviewed => const [
          ApplicationStatus.shortlisted,
          ApplicationStatus.rejected,
        ],
      ApplicationStatus.shortlisted => const [
          ApplicationStatus.interviewing,
          ApplicationStatus.rejected,
        ],
      ApplicationStatus.interviewing => const [
          ApplicationStatus.offered,
          ApplicationStatus.rejected,
        ],
      ApplicationStatus.offered => const [
          ApplicationStatus.hired,
          ApplicationStatus.rejected,
        ],
      _ => const [],
    };

AppStatus _interviewTone(InterviewStatus status) => switch (status) {
      InterviewStatus.accepted ||
      InterviewStatus.completed =>
        AppStatus.success,
      InterviewStatus.declined ||
      InterviewStatus.cancelled =>
        AppStatus.destructive,
      _ => AppStatus.info,
    };

String _dateTime(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: AppShape.space3),
        child: AppSurface(child: AppSkeleton(height: 80)),
      );
}
