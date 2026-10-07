import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/resume_import/data/resume_import_repository.dart';
import 'package:apsaratalent_mobile/features/career_scope/providers/career_scope_provider.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

final resumeImportRepositoryProvider =
    Provider((ref) => ResumeImportRepository(ref.watch(apiClientProvider)));

const resumeImportLabels = {
  'firstname': 'First name',
  'lastname': 'Last name',
  'job': 'Job title',
  'description': 'Bio',
  'location': 'Location',
  'yearsOfExperience': 'Years of experience',
  'availability': 'Availability',
  'skills': 'Skills',
  'careerScopes': 'Career scopes',
  'experiences': 'Work history',
  'educations': 'Education',
};

class ResumeImportButton extends ConsumerStatefulWidget {
  const ResumeImportButton(
      {super.key,
      required this.onImported,
      this.enabled = true,
      this.forSignup = false,
      this.onBusyChanged});
  final ValueChanged<Map<String, dynamic>> onImported;
  final ValueChanged<bool>? onBusyChanged;
  final bool enabled;
  final bool forSignup;
  @override
  ConsumerState<ResumeImportButton> createState() => _ResumeImportButtonState();
}

class _ResumeImportButtonState extends ConsumerState<ResumeImportButton> {
  bool _busy = false;
  String? _error;
  Future<void> _import() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    widget.onBusyChanged?.call(true);
    try {
      final file = await FilePicker.pickFile(
          type: FileType.custom, allowedExtensions: ['pdf']);
      if (file == null || !mounted) return;
      if ((await file.length() ?? 0) > maxResumeImportBytes) {
        throw ApiException(message: 'Choose a PDF smaller than 5 MB.');
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final catalog = ref.read(careerScopesProvider).valueOrNull;
      final parsed = await ref.read(resumeImportRepositoryProvider).parse(
          file.name, bytes,
          careerScopes: catalog?.map((s) => s.name).toSet());
      if (!mounted) return;
      final originalCount = (parsed['experiences'] as List? ?? []).length;
      if (widget.forSignup) {
        final rows = signupResumeExperiences(parsed['experiences']);
        if (rows.isEmpty) {
          parsed.remove('experiences');
        } else {
          parsed['experiences'] = rows;
        }
      }
      final skipped =
          originalCount - (parsed['experiences'] as List? ?? []).length;
      if (parsed.isEmpty) {
        throw ApiException(
            message:
                'Work history was incomplete. Enter your details manually and add work history from your profile later.');
      }
      final selected = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (_) => ResumeImportReview(
              data: parsed,
              notice: skipped > 0
                  ? '$skipped incomplete work-history entries were skipped. You can add them from your profile after signup.'
                  : null));
      if (selected != null && mounted) widget.onImported(selected);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException
            ? e.message
            : 'Could not import the resume. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        widget.onBusyChanged?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppButton(
            label: 'Import resume',
            variant: AppButtonVariant.outline,
            loading: _busy,
            onPressed: widget.enabled && !_busy ? _import : null),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(context.tr(
                'Upload a PDF up to 5 MB to prefill your profile. Review extracted details before applying them.'))),
        if (_error != null)
          Text(_error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]);
}

class ResumeImportReview extends StatefulWidget {
  const ResumeImportReview({super.key, required this.data, this.notice});
  final String? notice;
  final Map<String, dynamic> data;
  @override
  State<ResumeImportReview> createState() => _ResumeImportReviewState();
}

class _ResumeImportReviewState extends State<ResumeImportReview> {
  late final Set<String> _selected = widget.data.keys.toSet();
  String _display(dynamic value) => value is List
      ? value
          .map((row) => row is Map ? row.values.join(' · ') : '$row')
          .join('\n\n')
      : '$value';
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(context.tr('Review resume details')),
        content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(context.tr(
                  'Selected text fields replace form values. Skills, career scopes, work history and education are added to your draft. Your login details stay the same. Nothing is saved until you submit the form.')),
              if (widget.notice != null) Text(widget.notice!),
              for (final entry in widget.data.entries)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(resumeImportLabels[entry.key] ?? entry.key),
                  subtitle: Text(_display(entry.value)),
                  value: _selected.contains(entry.key),
                  onChanged: (value) => setState(() {
                    if (value == true) {
                      _selected.add(entry.key);
                    } else {
                      _selected.remove(entry.key);
                    }
                  }),
                ),
            ]))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('Cancel'))),
          TextButton(
              onPressed: _selected.isEmpty
                  ? null
                  : () => Navigator.pop(context,
                      {for (final key in _selected) key: widget.data[key]}),
              child: Text(context.tr('Apply selected'))),
        ],
      );
}
