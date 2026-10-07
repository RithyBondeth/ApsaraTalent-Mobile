import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/features/resume_builder/presentation/screens/resume_builder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/ai/presentation/ai_quota.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// Returns reviewed text to the calling form. Never saves or sends it itself.
class AiWritingScreen extends ConsumerStatefulWidget {
  const AiWritingScreen(
      {super.key,
      required this.contextData,
      this.initialText = '',
      this.bio = false});
  final Map<String, dynamic> contextData;
  final String initialText;
  final bool bio;
  @override
  ConsumerState<AiWritingScreen> createState() => _AiWritingScreenState();
}

class _AiWritingScreenState extends ConsumerState<AiWritingScreen> {
  late final _text = TextEditingController(text: widget.initialText);
  bool _busy = false;
  String? _error;
  String _pdfStyle = 'classic';
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _generate({bool polish = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final input = _text.text;
    final repository = ref.read(aiRepositoryProvider);
    try {
      final result = await runAiRequest(
          ref,
          () => widget.bio
              ? repository
                  .refineBio({...widget.contextData, 'currentText': input})
              : polish
                  ? repository.polish(input)
                  : repository.coverLetter(widget.contextData));
      if (mounted) setState(() => _text.text = result);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException
            ? e.message
            : 'Could not finish writing. Your draft is unchanged.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final bytes = await ref.read(resumeRepositoryProvider).coverLetterPdf({
        'employeeName': widget.contextData['employeeName'],
        if (widget.contextData['employeeJob'] != null)
          'employeeJob': widget.contextData['employeeJob'],
        'companyName': widget.contextData['companyName'],
        if (widget.contextData['companyIndustry'] != null)
          'companyIndustry': widget.contextData['companyIndustry'],
        'coverLetterText': _text.text.trim(),
        'style': _pdfStyle,
      });
      if (!mounted) return;
      await ref.read(resumePdfPreviewProvider)(bytes);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException
            ? e.message
            : 'Could not export the PDF. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exhausted =
        ref.watch(aiQuotaProvider).valueOrNull?.exhausted() ?? false;
    return AppScreen(
        appBar: AppBar(
            title: Text(
                context.tr(widget.bio ? 'AI bio writer' : 'AI cover letter'))),
        children: [
          const AiQuotaPanel(),
          Text(context.tr(
              'Review the draft for accuracy and edit it before using it. Nothing is saved or sent from this screen.')),
          if (_error != null)
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          TextField(
              controller: _text,
              enabled: !_busy,
              minLines: 6,
              maxLines: 14,
              maxLength: widget.bio ? 1000 : 5000,
              decoration: InputDecoration(
                  labelText: context
                      .tr(widget.bio ? 'Bio draft' : 'Cover-letter draft'),
                  alignLabelWithHint: true),
              onChanged: (_) => setState(() {})),
          AppButton(
              label: widget.bio ? 'Refine bio' : 'Generate cover letter',
              loading: _busy,
              onPressed: _busy || exhausted ? null : () => _generate()),
          if (!widget.bio)
            AppButton(
                label: 'Polish draft',
                variant: AppButtonVariant.outline,
                onPressed: _busy || exhausted || _text.text.trim().isEmpty
                    ? null
                    : () => _generate(polish: true)),
          if (!widget.bio)
            DropdownButtonFormField<String>(
                initialValue: _pdfStyle,
                decoration: InputDecoration(labelText: context.tr('PDF style')),
                items: [
                  for (final style in ['classic', 'modern', 'minimal', 'bold'])
                    DropdownMenuItem(
                        value: style, child: Text(context.tr(style)))
                ],
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _pdfStyle = value!)),
          if (!widget.bio)
            AppButton(
                label: 'Export cover-letter PDF',
                variant: AppButtonVariant.outline,
                onPressed: _busy ||
                        _text.text.trim().isEmpty ||
                        _text.text.length > 5000
                    ? null
                    : _exportPdf),
          AppButton(
              label: 'Use this draft',
              variant: AppButtonVariant.secondary,
              onPressed: _busy ||
                      _text.text.trim().isEmpty ||
                      _text.text.length > (widget.bio ? 1000 : 5000)
                  ? null
                  : () => Navigator.pop(context, _text.text.trim())),
        ]);
  }
}
