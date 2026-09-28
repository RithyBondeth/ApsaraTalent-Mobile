import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/providers/profile_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class CompanyJobsScreen extends ConsumerWidget {
  const CompanyJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return AppScreen(
      appBar: AppBar(title: const Text('Open positions')),
      onRefresh: () => ref.read(profileProvider.notifier).refresh(),
      children: profile.when(
        loading: () => const [Center(child: CircularProgressIndicator())],
        error: (error, _) => [
          PageState(
              variant: PageStateVariant.error,
              title: 'Positions could not load',
              description:
                  error is ApiException ? error.message : 'Please try again.',
              actionLabel: 'Try again',
              onAction: () => ref.invalidate(profileProvider))
        ],
        data: (value) {
          if (value is! CompanyProfile) {
            return const [
              PageState(
                  variant: PageStateVariant.empty,
                  title: 'Company account required',
                  description: 'Open positions belong to company profiles.')
            ];
          }
          return [
            PageBanner(
                eyebrow: 'Hiring',
                title: 'Open positions',
                subtitle:
                    'Create and maintain the roles candidates discover and match against.',
                stats: [
                  PageBannerStat(
                      icon: LucideIcons.briefcaseBusiness,
                      value: '${value.openPositionItems.length}',
                      label: 'positions')
                ]),
            AppButton(
                label: 'Create position',
                icon: LucideIcons.plus,
                fullWidth: true,
                onPressed: () => _edit(context, ref)),
            if (value.openPositionItems.isEmpty)
              const PageState(
                  variant: PageStateVariant.empty,
                  icon: LucideIcons.briefcase,
                  title: 'No open positions',
                  description:
                      'Create your first role to appear in job search and matching.'),
            for (final job in value.openPositionItems)
              _JobCard(
                  job: job,
                  onEdit: () => _edit(context, ref, job),
                  onDelete: () => _delete(context, ref, job)),
          ];
        },
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref,
      [ProfileJob? job]) async {
    final result = await showDialog<Map<String, dynamic>>(
        context: context, builder: (_) => _JobEditor(job: job));
    if (result == null || !context.mounted) return;
    try {
      await ref.read(profileProvider.notifier).saveOpenPosition(result);
      if (context.mounted) {
        _message(
            context, job == null ? 'Position created.' : 'Position updated.');
      }
    } on ApiException catch (error) {
      if (context.mounted) _message(context, error.message);
    }
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, ProfileJob job) async {
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Delete this position?'),
                content: Text(
                    '${job.title} will be removed from search and matching.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Keep')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'))
                ]));
    if (accepted != true || !context.mounted) return;
    try {
      await ref.read(profileProvider.notifier).deleteOpenPosition(job.id);
      if (context.mounted) _message(context, 'Position deleted.');
    } on ApiException catch (error) {
      if (context.mounted) _message(context, error.message);
    }
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard(
      {required this.job, required this.onEdit, required this.onDelete});
  final ProfileJob job;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => AppSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(job.title,
                  style: AppTypography.label.copyWith(
                      color: context.tokens.foreground,
                      fontSize: AppTypography.base))),
          PopupMenuButton<String>(
              onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete'))
                  ])
        ]),
        if (job.type != null || job.workMode != null)
          Text(
              [job.type, job.workMode]
                  .whereType<String>()
                  .map(_humanize)
                  .join(' · '),
              style: AppTypography.tiny
                  .copyWith(color: context.tokens.mutedForeground)),
        if (job.description case final text?) ...[
          const SizedBox(height: AppShape.space2),
          Text(text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.small
                  .copyWith(color: context.tokens.mutedForeground))
        ],
        if (job.skills.isNotEmpty) ...[
          const SizedBox(height: AppShape.space3),
          Wrap(
              spacing: AppShape.space2,
              runSpacing: AppShape.space2,
              children: [for (final skill in job.skills) AppTag(label: skill)])
        ],
        const SizedBox(height: AppShape.space3),
        Wrap(spacing: AppShape.space3, children: [
          if (job.location != null)
            MetaChip(icon: LucideIcons.mapPin, label: job.location!),
          if (job.openingsCount != null)
            MetaChip(
                icon: LucideIcons.users,
                label: '${job.openingsCount} openings'),
          if (job.deadlineDate != null)
            MetaChip(
                icon: LucideIcons.calendar, label: 'Closes ${job.deadlineDate}')
        ]),
      ]));
}

class _JobEditor extends StatefulWidget {
  const _JobEditor({this.job});
  final ProfileJob? job;
  @override
  State<_JobEditor> createState() => _JobEditorState();
}

class _JobEditorState extends State<_JobEditor> {
  late final Map<String, TextEditingController> c;
  late String workMode;
  String? error;
  @override
  void initState() {
    super.initState();
    final j = widget.job;
    c = {
      'title': TextEditingController(text: j?.title),
      'description': TextEditingController(text: j?.description),
      'type': TextEditingController(text: j?.type),
      'experienceRequired': TextEditingController(text: j?.experience),
      'educationRequired': TextEditingController(text: j?.education),
      'skillsRequired': TextEditingController(text: j?.skills.join(', ')),
      'location': TextEditingController(text: j?.location),
      'languagesRequired':
          TextEditingController(text: j?.languagesRequired.join(', ')),
      'salaryMin':
          TextEditingController(text: j?.salaryMin?.toStringAsFixed(0)),
      'salaryMax':
          TextEditingController(text: j?.salaryMax?.toStringAsFixed(0)),
      'salaryCurrency': TextEditingController(text: j?.salaryCurrency ?? 'USD'),
      'openingsCount':
          TextEditingController(text: j?.openingsCount?.toString()),
      'expireDate': TextEditingController(text: j?.deadlineDate),
    };
    workMode = j?.workMode ?? 'onsite';
  }

  @override
  void dispose() {
    for (final x in c.values) {
      x.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Text(widget.job == null ? 'Create position' : 'Edit position'),
          content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                AppInput(
                    controller: c['title'],
                    labelText: 'Job title',
                    errorText: error),
                const SizedBox(height: AppShape.space3),
                AppInput(
                    controller: c['description'],
                    labelText: 'Description',
                    minLines: 3,
                    maxLines: 5),
                const SizedBox(height: AppShape.space3),
                AppInput(
                    controller: c['type'],
                    labelText: 'Employment type',
                    hintText: 'Full-time'),
                const SizedBox(height: AppShape.space3),
                DropdownButtonFormField<String>(
                    initialValue: workMode,
                    decoration: const InputDecoration(
                        labelText: 'Work mode', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'onsite', child: Text('On-site')),
                      DropdownMenuItem(value: 'remote', child: Text('Remote')),
                      DropdownMenuItem(value: 'hybrid', child: Text('Hybrid'))
                    ],
                    onChanged: (v) => workMode = v ?? workMode),
                const SizedBox(height: AppShape.space3),
                AppInput(controller: c['location'], labelText: 'Location'),
                const SizedBox(height: AppShape.space3),
                AppInput(
                    controller: c['skillsRequired'],
                    labelText: 'Required skills',
                    hintText: 'Flutter, Dart, REST APIs'),
                const SizedBox(height: AppShape.space3),
                AppInput(
                    controller: c['experienceRequired'],
                    labelText: 'Experience required'),
                const SizedBox(height: AppShape.space3),
                AppInput(
                    controller: c['educationRequired'],
                    labelText: 'Education required'),
                const SizedBox(height: AppShape.space3),
                AppInput(
                    controller: c['languagesRequired'],
                    labelText: 'Languages',
                    hintText: 'Khmer, English'),
                const SizedBox(height: AppShape.space3),
                Row(children: [
                  Expanded(
                      child: AppInput(
                          controller: c['salaryMin'],
                          labelText: 'Minimum salary',
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: AppShape.space2),
                  Expanded(
                      child: AppInput(
                          controller: c['salaryMax'],
                          labelText: 'Maximum salary',
                          keyboardType: TextInputType.number))
                ]),
                const SizedBox(height: AppShape.space3),
                Row(children: [
                  Expanded(
                      child: AppInput(
                          controller: c['salaryCurrency'],
                          labelText: 'Currency')),
                  const SizedBox(width: AppShape.space2),
                  Expanded(
                      child: AppInput(
                          controller: c['openingsCount'],
                          labelText: 'Openings',
                          keyboardType: TextInputType.number))
                ]),
                const SizedBox(height: AppShape.space3),
                AppInput(
                    controller: c['expireDate'],
                    labelText: 'Deadline',
                    hintText: 'YYYY-MM-DD'),
              ]))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(onPressed: _save, child: const Text('Save'))
          ]);

  void _save() {
    final title = c['title']!.text.trim();
    if (title.isEmpty) {
      setState(() => error = 'Job title is required.');
      return;
    }
    final data = <String, dynamic>{
      if (widget.job != null) 'id': widget.job!.id,
      'title': title,
      'workMode': workMode
    };
    for (final key in [
      'description',
      'type',
      'experienceRequired',
      'educationRequired',
      'skillsRequired',
      'location',
      'salaryCurrency'
    ]) {
      final v = c[key]!.text.trim();
      if (v.isNotEmpty) data[key] = v;
    }
    for (final key in ['salaryMin', 'salaryMax']) {
      final v = double.tryParse(c[key]!.text.trim());
      if (v != null && v > 0) data[key] = v;
    }
    final openings = int.tryParse(c['openingsCount']!.text.trim());
    if (openings != null && openings > 0) data['openingsCount'] = openings;
    final languages = c['languagesRequired']!
        .text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (languages.isNotEmpty) data['languagesRequired'] = languages;
    final deadline = c['expireDate']!.text.trim();
    if (deadline.isNotEmpty) {
      final parsed = _parseDeadline(deadline);
      if (parsed == null) {
        setState(() => error = 'Use YYYY-MM-DD for the deadline.');
        return;
      }
      data['expireDate'] = parsed.toIso8601String();
    }
    Navigator.pop(context, data);
  }
}

DateTime? _parseDeadline(String value) {
  final iso = DateTime.tryParse(value);
  if (iso != null) return iso;
  final parts = value.split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  final result = DateTime(year, month, day);
  return result.day == day && result.month == month && result.year == year
      ? result
      : null;
}

String _humanize(String value) => value
    .replaceAll('_', ' ')
    .split(' ')
    .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
    .join(' ');
void _message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
