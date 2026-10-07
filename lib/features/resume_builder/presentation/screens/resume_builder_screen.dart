import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'resume_ai_tools_screen.dart';
import 'resume_design_screen.dart';
import 'package:apsaratalent_mobile/features/ai/presentation/ai_quota.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'my_resumes_screen.dart';
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

// Keep native file handling at a boundary so complete UI flows can run in CI.
final resumePdfPreviewProvider =
    Provider<Future<void> Function(Uint8List)>((ref) => (bytes) async {
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
        });

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
  String? _draftId;
  int? _revision;
  String _name = 'My resume';
  bool _unsynced = false;
  bool _saved = false;
  String? _saveError;
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
      final recovery =
          await ref.read(resumeDraftStoreProvider).recovery(profile.id);
      Map<String, dynamic>? remote;
      if (recovery == null && saved == null) {
        final repository = ref.read(resumeRepositoryProvider);
        final records = await repository.drafts();
        if (records.isNotEmpty) {
          remote = await repository.draft(records.first['id'] as String);
        }
      }
      if (!mounted) return;
      setState(() {
        _templates = templates;
        final record = recovery ?? remote;
        _draftId = record?['id'] as String?;
        _revision = record?['revision'] as int?;
        _name = record?['name'] as String? ?? 'My resume';
        _unsynced = recovery != null || saved != null;
        _saved = remote != null;
        _draft = (record == null
                ? saved
                : Map<String, dynamic>.from(record['content'] as Map)) ??
            (resumeFromProfile(profile, email)
              ..['template'] = templates.first['templateKey']);
        _restored = saved != null || recovery != null;
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
    if (draft == null || profile is! EmployeeProfile || _savingDraft) return;
    final repository = ref.read(resumeRepositoryProvider);
    final store = ref.read(resumeDraftStoreProvider);
    final snapshot =
        Map<String, dynamic>.from(jsonDecode(jsonEncode(draft)) as Map);
    _draftId ??= const Uuid().v4();
    if (mounted) {
      setState(() {
        _savingDraft = true;
        _unsynced = true;
        _saveError = null;
      });
    }
    try {
      await store.saveRecovery(profile.id, {
        'id': _draftId,
        'revision': _revision,
        'name': _name,
        'content': snapshot
      });
      final record = await repository.saveDraft(_name, snapshot,
          id: _draftId, revision: _revision);
      _draftId = record['id'] as String;
      _revision = record['revision'] as int;
      await store.clear(profile.id);
      await store.clearRecovery(profile.id);
      if (mounted) {
        setState(() {
          _unsynced = false;
          _saved = true;
          _restored = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _saveError = _message(e));
    } finally {
      if (mounted) setState(() => _savingDraft = false);
    }
  }

  Future<void> _clearDraft() async {
    if (_unsynced) {
      final discard = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(context.tr('Discard local changes?')),
                content: Text(context
                    .tr('These changes have not been saved to your account.')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.tr('Cancel'))),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.tr('Discard')))
                ],
              ));
      if (!mounted || discard != true) return;
    }
    final profile = ref.read(profileProvider).value;
    if (profile is! EmployeeProfile) return;
    await ref.read(resumeDraftStoreProvider).clear(profile.id);
    await ref.read(resumeDraftStoreProvider).clearRecovery(profile.id);
    if (!mounted) return;
    final email =
        ref.read(authSessionProvider).value?.user?.email ?? profile.email ?? '';
    setState(() {
      _draft = resumeFromProfile(profile, email)
        ..['template'] = _templates.first['templateKey'];
      _restored = false;
      _generated = false;
      _draftId = null;
      _revision = null;
      _name = 'My resume';
      _saved = false;
      _unsynced = false;
      _saveError = null;
    });
  }

  Future<void> _myResumes() async {
    final record = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
            builder: (_) => MyResumesScreen(
                repository: ref.read(resumeRepositoryProvider))));
    if (!mounted) return;
    if (record == null) {
      // A rename/delete in the list may have changed the current record.
      await _load();
      return;
    }
    if (record['new'] == true) {
      await _clearDraft();
      return;
    }
    setState(() {
      _draft = Map<String, dynamic>.from(record['content'] as Map);
      _draftId = record['id'] as String;
      _revision = record['revision'] as int;
      _name = record['name'] as String;
      _saved = true;
      _unsynced = false;
      _restored = false;
      _generated = false;
      _error = null;
      _saveError = null;
    });
  }

  Future<void> _tools({bool fromText = false, bool design = false}) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
            builder: (_) => design
                ? ResumeDesignScreen(draft: _draft!)
                : ResumeAiToolsScreen(draft: _draft!, fromText: fromText)));
    if (!mounted || result == null) return;
    setState(() {
      _draft = result;
      if (_draft!['design'] == null) _draft!.remove('design');
    });
    await _persistDraft();
  }

  Future<void> _reloadSaved() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(context.tr('Discard edits and reload?')),
                content: Text(context.tr(
                    'This replaces local edits with the latest saved version.')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.tr('Cancel'))),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.tr('Reload')))
                ]));
    if (confirmed != true || !mounted || _draftId == null) return;
    setState(() => _savingDraft = true);
    try {
      final record = await ref.read(resumeRepositoryProvider).draft(_draftId!);
      final profile = ref.read(profileProvider).value;
      if (profile is EmployeeProfile) {
        await ref.read(resumeDraftStoreProvider).clear(profile.id);
        await ref.read(resumeDraftStoreProvider).clearRecovery(profile.id);
      }
      if (!mounted) return;
      setState(() {
        _draft = Map<String, dynamic>.from(record['content'] as Map);
        _revision = record['revision'] as int;
        _name = record['name'] as String;
        _unsynced = false;
        _saved = true;
        _restored = false;
        _saveError = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _saveError = _message(e));
      }
    } finally {
      if (mounted) {
        setState(() => _savingDraft = false);
      }
    }
  }

  Future<void> _rename() async {
    final result =
        await _edit('Resume name', {'Name': _name}, limits: {'Name': 120});
    if (!mounted || result == null || result['Name']!.isEmpty) return;
    setState(() => _name = result['Name']!);
    await _persistDraft();
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
        await ref.read(resumePdfPreviewProvider)(bytes);
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
        title: Text(context.tr(title)),
        content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final e in controllers.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                      controller: e.value,
                      decoration: InputDecoration(labelText: context.tr(e.key)),
                      minLines: 1,
                      maxLines: 5,
                      maxLength: limits[e.key] ?? 5000),
                ),
            ]))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('Cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(context, {
                    for (final e in controllers.entries)
                      e.key: e.value.text.trim()
                  }),
              child: Text(context.tr('Save'))),
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
    // Keep the auto-disposed profile alive while edits are being saved.
    ref.watch(profileProvider);
    final draft = _draft;
    return AppScreen(children: [
      const PageBanner(
          eyebrow: 'Resume builder',
          title: 'Build your resume',
          subtitle:
              'Create resumes for different roles and save them to your account.'),
      TextButton.icon(
          onPressed:
              _loading || draft == null || _busy || _savingDraft || _unsynced
                  ? null
                  : _myResumes,
          icon: const Icon(Icons.folder_outlined),
          label: Text(context.tr('My resumes'))),
      if (_loading) const Center(child: CircularProgressIndicator()),
      if (_error != null)
        PageState(
            variant: PageStateVariant.error,
            title: _error!,
            compact: true,
            actionLabel: draft == null ? 'Retry' : null,
            onAction: draft == null ? _load : null),
      if (draft != null) ...[
        ListTile(
            title: Text(_name),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _busy || _savingDraft ? null : _rename),
        Text(_savingDraft
            ? 'Saving to your account…'
            : _unsynced
                ? 'Changes are not synced yet.'
                : _saved
                    ? 'Saved to your account'
                    : 'New resume — save to keep it'),
        if (_saveError != null) Text(_saveError!),
        if (!_saved || _unsynced)
          TextButton(
              onPressed: _savingDraft || _busy ? null : _persistDraft,
              child:
                  Text(context.tr(_unsynced ? 'Retry save' : 'Save resume'))),
        if (_saveError != null && _revision != null)
          TextButton(
              onPressed: _savingDraft || _busy ? null : _reloadSaved,
              child: Text(context.tr('Reload saved resume'))),
        if (_saveError != null)
          TextButton(
              onPressed: _savingDraft || _busy
                  ? null
                  : () {
                      _draftId = null;
                      _revision = null;
                      _persistDraft();
                    },
              child: Text(context.tr('Save as new resume'))),
        if (_restored)
          AppSurface(
            child: Row(children: [
              Expanded(
                  child: Text(context
                      .tr('Local draft recovered. Save it to your account.'))),
              TextButton(
                  onPressed: _savingDraft || _busy ? null : _clearDraft,
                  child: Text(context.tr('Start over'))),
            ]),
          ),
        if (_savingDraft) const LinearProgressIndicator(minHeight: 2),
        AbsorbPointer(
            absorbing: _busy || _savingDraft,
            child: Column(children: [
              DropdownButtonFormField<String>(
                key: ValueKey('${_draftId}_${draft['template']}'),
                initialValue:
                    _templates.any((t) => t['templateKey'] == draft['template'])
                        ? draft['template'] as String
                        : null,
                decoration: InputDecoration(labelText: context.tr('Template')),
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
                    });
                    _persistDraft();
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                  title: Text(context.tr('Personal details')),
                  subtitle: Text('${draft['personalInfo']['fullName']}'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: _personal),
              ListTile(
                  title: Text(context
                      .tr(_generated ? 'Summary · AI draft' : 'Summary')),
                  subtitle: Text('${draft['summary'] ?? 'Add a summary'}',
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  onTap: () => _text('summary', 'Summary')),
              ListTile(
                  title: Text(context.tr('Education')),
                  subtitle: Text('${draft['education'] ?? ''}',
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  onTap: () => _text('education', 'Education')),
              ListTile(
                  title: Text(context.tr('Skills')),
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
                    tooltip: context.tr('Remove experience'),
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
                    label: Text(context.tr('Add experience'))),
            ])),
        const SizedBox(height: 16),
        Text(context.tr(
            'AI rewrites your resume content. Review generated details before exporting.')),
        const SizedBox(height: 12),
        const AiQuotaPanel(cvGeneration: true),
        AppButton(
            label: 'Resume from text',
            variant: AppButtonVariant.outline,
            onPressed:
                _busy || _savingDraft ? null : () => _tools(fromText: true)),
        const SizedBox(height: 12),
        AppButton(
            label: 'Optimize resume',
            variant: AppButtonVariant.outline,
            onPressed: _busy || _savingDraft ? null : () => _tools()),
        const SizedBox(height: 12),
        AppButton(
            label: 'Resume design',
            variant: AppButtonVariant.outline,
            onPressed:
                _busy || _savingDraft ? null : () => _tools(design: true)),
        const SizedBox(height: 12),
        AppButton(
            label: 'Generate AI draft',
            variant: AppButtonVariant.outline,
            onPressed: _busy ||
                    _savingDraft ||
                    (ref
                            .watch(aiQuotaProvider)
                            .valueOrNull
                            ?.exhausted(cvGeneration: true) ??
                        false)
                ? null
                : () => _run(true)),
        const SizedBox(height: 12),
        AppButton(
            label: 'Preview PDF',
            onPressed: _busy || _savingDraft ? null : () => _run(false)),
        if (_busy)
          const Padding(
              padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
      ],
    ]);
  }
}
