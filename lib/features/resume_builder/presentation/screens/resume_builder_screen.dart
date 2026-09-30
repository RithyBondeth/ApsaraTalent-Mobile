import 'package:apsaratalent_mobile/features/ai/presentation/ai_quota.dart';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/profile/providers/profile_notifier.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/resume_builder/data/resume_repository.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

final resumeRepositoryProvider =
    Provider((ref) => ResumeRepository(ref.watch(apiClientProvider)));
final resumeDraftStoreProvider = Provider((ref) => ResumeDraftStore());

@RoutePage()
class ResumeBuilderScreen extends ConsumerStatefulWidget {
  const ResumeBuilderScreen({super.key});
  @override
  ConsumerState<ResumeBuilderScreen> createState() =>
      _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends ConsumerState<ResumeBuilderScreen> {
  Map<String, dynamic>? _draft;
  List<Map<String, dynamic>> _templates = [];
  bool _loading = true;
  bool _busy = false;
  bool _generated = false;
  bool _restored = false;
  bool _savingDraft = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ref.read(profileProvider.future);
      if (profile is! EmployeeProfile) {
        throw ApiException(
            message: 'A candidate profile is required to build a resume.');
      }
      final templates = await ref.read(resumeRepositoryProvider).templates();
      if (templates.isEmpty) {
        throw ApiException(message: 'No resume templates are available yet.');
      }
      final email = ref.read(authSessionProvider).value?.user?.email ??
          profile.email ??
          '';
      final saved = await ref.read(resumeDraftStoreProvider).read(profile.id);
      if (!mounted) return;
      setState(() {
        _templates = templates;
        _draft = saved ??
            (resumeFromProfile(profile, email)
              ..['template'] = templates.first['templateKey']);
        _restored = saved != null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _message(Object e) => e is ApiException
      ? e.message
      : 'Could not complete this action. Please try again.';

  Future<void> _persistDraft() async {
    final draft = _draft;
    final profile = ref.read(profileProvider).value;
    if (draft == null || profile is! EmployeeProfile) return;
    if (mounted) setState(() => _savingDraft = true);
    try {
      await ref.read(resumeDraftStoreProvider).write(profile.id, draft);
    } finally {
      if (mounted) setState(() => _savingDraft = false);
    }
  }

  Future<void> _clearDraft() async {
    final profile = ref.read(profileProvider).value;
    if (profile is! EmployeeProfile) return;
    await ref.read(resumeDraftStoreProvider).clear(profile.id);
    if (!mounted) return;
    final email =
        ref.read(authSessionProvider).value?.user?.email ?? profile.email ?? '';
    setState(() {
      _draft = resumeFromProfile(profile, email)
        ..['template'] = _templates.first['templateKey'];
      _restored = false;
      _generated = false;
    });
  }

  Future<void> _run(bool generate) async {
    final personal = _draft!['personalInfo'] as Map;
    if ('${personal['fullName']}'.trim().isEmpty ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
            .hasMatch('${personal['email']}')) {
      setState(() => _error =
          'Add your name and a valid email in Personal details first.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repository = ref.read(resumeRepositoryProvider);
      if (generate) {
        final result = await runAiRequest(
            ref, () => repository.generate(_draft!),
            cvGeneration: true);
        if (mounted) {
          setState(() {
            _draft = result;
            _generated = true;
          });
          await _persistDraft();
        }
      } else {
        final bytes = await repository.build(_draft!);
        if (!mounted) return;
        final directory = await getTemporaryDirectory();
        final file = File(
            '${directory.path}/resume-${DateTime.now().microsecondsSinceEpoch}.pdf');
        await file.writeAsBytes(bytes, flush: true);
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          throw ApiException(
              message:
                  'PDF created, but it could not be opened: ${result.message}');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Map<String, String>?> _edit(String title, Map<String, String> values,
      {Map<String, int> limits = const {}}) async {
    final controllers = {
      for (final e in values.entries)
        e.key: TextEditingController(text: e.value)
    };
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final e in controllers.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                      controller: e.value,
                      decoration: InputDecoration(labelText: e.key),
                      minLines: 1,
                      maxLines: 5,
                      maxLength: limits[e.key] ?? 5000),
                ),
            ]))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, {
                    for (final e in controllers.entries)
                      e.key: e.value.text.trim()
                  }),
              child: const Text('Save')),
        ],
      ),
    );
    // The dialog can still be animating out; dispose after its transition.
    Future.delayed(const Duration(milliseconds: 400), () {
      for (final c in controllers.values) {
        c.dispose();
      }
    });
    return result;
  }

  Future<void> _personal() async {
    final p = Map<String, dynamic>.from(_draft!['personalInfo']);
    const fields = {
      'Name': 'fullName',
      'Email': 'email',
      'Phone': 'phone',
      'Location': 'location',
      'Job title': 'job'
    };
    final result = await _edit('Personal details', {
      for (final e in fields.entries) e.key: '${p[e.value] ?? ''}'
    }, limits: {
      'Name': 200,
      'Email': 320,
      'Phone': 80,
      'Location': 250,
      'Job title': 250
    });
    if (result != null && mounted) {
      setState(() => _draft!['personalInfo'] = {
            ...p,
            for (final e in fields.entries) e.value: result[e.key]
          });
      await _persistDraft();
    }
  }

  Future<void> _text(String key, String title, {bool list = false}) async {
    final value = _draft![key];
    final result = await _edit(
        title, {title: list ? (value as List).join('\n') : '${value ?? ''}'});
    if (result == null || !mounted) return;
    final text = result[title]!;
    final items = text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (list && (items.length > 100 || items.any((s) => s.length > 100))) {
      setState(() =>
          _error = 'Use up to 100 skills, each no longer than 100 characters.');
      return;
    }
    setState(() => _draft![key] = list ? items : text);
    await _persistDraft();
  }

  Future<void> _experience([int? index]) async {
    final rows = List<dynamic>.from(_draft!['experience']);
    final row = index == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(rows[index]);
    const fields = {
      'Company': 'company',
      'Position': 'position',
      'Start date': 'startDate',
      'End date': 'endDate',
      'Description': 'description'
    };
    final result = await _edit('Work experience', {
      for (final e in fields.entries) e.key: '${row[e.value] ?? ''}',
      'Achievements (one per line)':
          (row['achievements'] as List? ?? []).join('\n'),
    }, limits: {
      'Company': 250,
      'Position': 250,
      'Start date': 100,
      'End date': 100
    });
    if (result == null || !mounted) return;
    final achievements = result['Achievements (one per line)']!
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (achievements.length > 30 || achievements.any((s) => s.length > 1000)) {
      setState(() => _error =
          'Use up to 30 achievements of at most 1,000 characters each.');
      return;
    }
    final updated = {
      for (final e in fields.entries) e.value: result[e.key],
      'achievements': achievements
    };
    if (index == null) {
      rows.add(updated);
    } else {
      rows[index] = updated;
    }
    setState(() => _draft!['experience'] = rows);
    await _persistDraft();
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    return AppScreen(children: [
      const PageBanner(
          eyebrow: 'Resume builder',
          title: 'Build your resume',
          subtitle:
              'Review your profile details, choose a template, and open your PDF. Edits are saved privately on this device.'),
      if (_loading) const Center(child: CircularProgressIndicator()),
      if (_error != null)
        PageState(
            variant: PageStateVariant.error,
            title: _error!,
            compact: true,
            actionLabel: draft == null ? 'Retry' : null,
            onAction: draft == null ? _load : null),
      if (draft != null) ...[
        if (_restored)
          AppSurface(
            child: Row(children: [
              const Expanded(
                  child: Text('Saved draft restored from this device.')),
              TextButton(
                  onPressed: _clearDraft, child: const Text('Start over')),
            ]),
          ),
        if (_savingDraft) const LinearProgressIndicator(minHeight: 2),
        AbsorbPointer(
            absorbing: _busy,
            child: Column(children: [
              DropdownButtonFormField<String>(
                initialValue: draft['template'] as String,
                decoration: const InputDecoration(labelText: 'Template'),
                isExpanded: true,
                items: [
                  for (final t in _templates)
                    DropdownMenuItem(
                        value: t['templateKey'] as String,
                        child: Text('${t['title']}',
                            overflow: TextOverflow.ellipsis))
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      draft['template'] = value;
                      draft.remove('design');
                    });
                    _persistDraft();
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                  title: const Text('Personal details'),
                  subtitle: Text('${draft['personalInfo']['fullName']}'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: _personal),
              ListTile(
                  title: Text(_generated ? 'Summary · AI draft' : 'Summary'),
                  subtitle: Text('${draft['summary'] ?? 'Add a summary'}',
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  onTap: () => _text('summary', 'Summary')),
              ListTile(
                  title: const Text('Education'),
                  subtitle: Text('${draft['education'] ?? ''}',
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  onTap: () => _text('education', 'Education')),
              ListTile(
                  title: const Text('Skills'),
                  subtitle: Text((draft['skills'] as List).join(', '),
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  onTap: () =>
                      _text('skills', 'Skills (one per line)', list: true)),
              const SectionTitle(title: 'Work history'),
              for (var i = 0; i < (draft['experience'] as List).length; i++)
                ListTile(
                  title: Text('${draft['experience'][i]['position']}'),
                  subtitle: Text('${draft['experience'][i]['company']}'),
                  onTap: () => _experience(i),
                  trailing: IconButton(
                    tooltip: 'Remove experience',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() {
                      (draft['experience'] as List).removeAt(i);
                      _persistDraft();
                    }),
                  ),
                ),
              if ((draft['experience'] as List).length < 30)
                TextButton.icon(
                    onPressed: () => _experience(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add experience')),
            ])),
        const SizedBox(height: 16),
        const Text(
            'AI rewrites your resume content. Review generated details before exporting.'),
        const SizedBox(height: 12),
        const AiQuotaPanel(cvGeneration: true),
        AppButton(
            label: 'Generate AI draft',
            variant: AppButtonVariant.outline,
            onPressed: _busy ||
                    (ref
                            .watch(aiQuotaProvider)
                            .value
                            ?.exhausted(cvGeneration: true) ??
                        false)
                ? null
                : () => _run(true)),
        const SizedBox(height: 12),
        AppButton(
            label: 'Preview PDF', onPressed: _busy ? null : () => _run(false)),
        if (_busy)
          const Padding(
              padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
      ],
    ]);
  }
}
