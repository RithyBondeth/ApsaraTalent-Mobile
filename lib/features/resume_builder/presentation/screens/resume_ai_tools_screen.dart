import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/features/ai/presentation/ai_quota.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'resume_builder_screen.dart';

/// Suggestions remain separate until the person explicitly applies them.
class ResumeAiToolsScreen extends ConsumerStatefulWidget {
  const ResumeAiToolsScreen(
      {super.key, required this.draft, this.fromText = false});
  final Map<String, dynamic> draft;
  final bool fromText;
  @override
  ConsumerState<ResumeAiToolsScreen> createState() => _ResumeAiToolsState();
}

class _ResumeAiToolsState extends ConsumerState<ResumeAiToolsScreen> {
  final _source = TextEditingController();
  final _summary = TextEditingController();
  final _skills = TextEditingController();
  Map<String, dynamic>? _result;
  final _selected = <int>{};
  bool _summarySelected = true, _skillsSelected = true, _busy = false;
  String? _error;
  @override
  void dispose() {
    _source.dispose();
    _summary.dispose();
    _skills.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repository = ref.read(resumeRepositoryProvider);
      final result = await runAiRequest(
          ref,
          () => widget.fromText
              ? repository.generateFromText(
                  _source.text, widget.draft['template'] as String)
              : repository.optimize(widget.draft),
          cvGeneration: widget.fromText);
      if (!mounted) return;
      setState(() {
        _result = result;
        _selected.clear();
        _summary.text =
            '${result[widget.fromText ? 'summary' : 'suggestedSummary'] ?? ''}';
        _skills.text =
            (result[widget.fromText ? 'skills' : 'suggestedSkills'] as List)
                .join('\n');
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException
            ? e.message
            : 'Could not generate suggestions. Your draft is unchanged.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _apply() {
    final result = _result!;
    final draft = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(widget.fromText ? result : widget.draft)) as Map);
    final skills = _skills.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    final combinedSkills = {
      ...(widget.draft['skills'] as List).cast<String>(),
      ...skills
    };
    if ((!widget.fromText && _skillsSelected && combinedSkills.length > 100) ||
        skills.length > 100 ||
        skills.any((s) => s.length > 200)) {
      setState(() =>
          _error = 'Use up to 100 skills, each no longer than 200 characters.');
      return;
    }
    if (widget.fromText || _summarySelected) {
      draft['summary'] = _summary.text.trim();
    }
    if (widget.fromText) {
      draft['skills'] = skills;
    } else if (_skillsSelected) {
      draft['skills'] = combinedSkills.toList();
    }
    if (!widget.fromText) {
      final rows = draft['experience'] as List;
      for (final i in _selected) {
        final suggestion = (result['experienceSuggestions'] as List)[i] as Map;
        rows[suggestion['index'] as int] = {
          ...rows[suggestion['index'] as int] as Map,
          'description': suggestion['improvedDescription'],
          'achievements': suggestion['improvedAchievements']
        };
      }
    }
    Navigator.pop(context, draft);
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final exhausted = ref
            .watch(aiQuotaProvider)
            .valueOrNull
            ?.exhausted(cvGeneration: widget.fromText) ??
        false;
    return AppScreen(
        appBar: AppBar(
            title: Text(context
                .tr(widget.fromText ? 'Resume from text' : 'Optimize resume'))),
        children: [
          AiQuotaPanel(cvGeneration: widget.fromText),
          Text(context
              .tr('Review AI suggestions for accuracy before applying them.')),
          if (widget.fromText)
            TextField(
                controller: _source,
                enabled: !_busy,
                minLines: 5,
                maxLines: 12,
                maxLength: 8000,
                decoration: InputDecoration(
                    labelText: context.tr('Paste your experience and skills')),
                onChanged: (_) => setState(() {})),
          if (_error != null)
            Text(context.tr(_error!),
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          AppButton(
              label: 'Generate suggestions',
              loading: _busy,
              onPressed: _busy ||
                      exhausted ||
                      (widget.fromText && _source.text.trim().length < 20)
                  ? null
                  : _generate),
          if (result != null) ...[
            if (widget.fromText) ...[
              Text(
                  '${result['personalInfo']['fullName']} · ${result['personalInfo']['email']}'),
              Text('${result['education'] ?? ''}'),
              for (final row in result['experience'] as List)
                ListTile(
                    title: Text('${row['position']} · ${row['company']}'),
                    subtitle: Text('${row['description']}')),
            ] else
              Text(result['overallFeedback'] as String),
            if (!widget.fromText)
              CheckboxListTile(
                  title: Text(context.tr('Apply summary')),
                  value: _summarySelected,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() => _summarySelected = v!)),
            TextField(
                controller: _summary,
                enabled: !_busy,
                maxLength: 5000,
                minLines: 3,
                maxLines: 8,
                decoration: InputDecoration(
                    labelText: context.tr('Suggested summary'))),
            if (!widget.fromText)
              CheckboxListTile(
                  title: Text(context.tr('Add suggested skills')),
                  value: _skillsSelected,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() => _skillsSelected = v!)),
            TextField(
                controller: _skills,
                enabled: !_busy,
                minLines: 3,
                maxLines: 8,
                decoration: InputDecoration(
                    labelText: context.tr('Skills (one per line)'))),
            if (!widget.fromText)
              for (var i = 0;
                  i < (result['experienceSuggestions'] as List).length;
                  i++)
                CheckboxListTile(
                    value: _selected.contains(i),
                    title: Text(
                        '${(widget.draft['experience'] as List)[result['experienceSuggestions'][i]['index']]['position']}'),
                    subtitle: Text(
                        '${result['experienceSuggestions'][i]['improvedDescription']}\n${(result['experienceSuggestions'][i]['improvedAchievements'] as List).join('\n')}'),
                    onChanged: _busy
                        ? null
                        : (v) => setState(() {
                              if (v == true) {
                                _selected.add(i);
                              } else {
                                _selected.remove(i);
                              }
                            })),
            AppButton(
                label: 'Apply reviewed changes',
                onPressed: _busy ? null : _apply),
          ],
        ]);
  }
}
