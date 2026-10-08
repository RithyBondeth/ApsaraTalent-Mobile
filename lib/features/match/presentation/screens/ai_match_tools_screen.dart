import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/features/ai/presentation/ai_quota.dart';
import 'package:path_provider/path_provider.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/match/domain/entities/ai_match_tools.dart';
import 'package:apsaratalent_mobile/features/match/domain/entities/match_profile.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/match/providers/ai_match_tools_provider.dart';
import 'package:apsaratalent_mobile/features/match/data/interview_prep_export.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _Tool { explanation, gaps, interview }

@RoutePage()
class AiMatchToolsScreen extends ConsumerStatefulWidget {
  const AiMatchToolsScreen(
      {super.key,
      required this.match,
      required this.employeeId,
      required this.companyId});
  final MatchProfile match;
  final String employeeId;
  final String companyId;
  @override
  ConsumerState<AiMatchToolsScreen> createState() => _AiMatchToolsScreenState();
}

class _AiMatchToolsScreenState extends ConsumerState<AiMatchToolsScreen> {
  _Tool _tool = _Tool.explanation;
  bool _loading = false;
  Object? _error;
  AiMatchExplanation? _explanation;
  SkillGapAnalysis? _gaps;
  List<InterviewQuestion>? _questions;
  List<InterviewQuestion> _questionPreview = const [];
  bool _exporting = false;
  final _round = TextEditingController();

  @override
  void dispose() {
    _round.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
      _questionPreview = const [];
    });
    final repository = ref.read(aiMatchToolsRepositoryProvider);
    try {
      await runAiRequest(ref, () async {
        switch (_tool) {
          case _Tool.explanation:
            final result = await repository.explanation(
                widget.employeeId, widget.companyId,
                lang: Localizations.localeOf(context).languageCode);
            if (mounted) setState(() => _explanation = result);
          case _Tool.gaps:
            final result = await repository.skillGap(
                widget.employeeId, widget.companyId,
                lang: Localizations.localeOf(context).languageCode);
            if (mounted) setState(() => _gaps = result);
          case _Tool.interview:
            final result = await repository.interviewPrepStream(
                widget.employeeId, widget.companyId,
                interviewTitle: _round.text, onQuestions: (questions) {
              if (mounted) setState(() => _questionPreview = questions);
            });
            if (mounted) setState(() => _questions = result);
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _questionPreview = const [];
        });
      }
    }
  }

  Future<void> _exportInterviewPrep() async {
    final questions = _questions;
    if (questions == null || questions.isEmpty) return;
    setState(() {
      _exporting = true;
      _error = null;
    });
    try {
      final bytes =
          await ref.read(aiMatchToolsRepositoryProvider).interviewPrepPdf(
                interviewTitle: _round.text,
                companyName: widget.match.profile.displayName,
                companyIndustry: switch (widget.match.profile) {
                  FeedCompany(:final industry) => industry,
                  _ => null,
                },
                questions: questions,
              );
      if (!mounted) return;
      final dir = await getTemporaryDirectory();
      await saveAndOpenInterviewPdf(bytes, dir,
          filename:
              'interview-prep-${DateTime.now().microsecondsSinceEpoch}.pdf');
    } catch (error) {
      if (mounted) {
        setState(() => _error =
            error is ApiException ? error : 'Could not export interview prep.');
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final generated = switch (_tool) {
      _Tool.explanation => _explanation != null,
      _Tool.gaps => _gaps != null,
      _Tool.interview => _questions != null
    };
    return AppScreen(
      appBar: AppBar(title: Text(context.tr('AI match tools'))),
      children: [
        PageBanner(
          eyebrow: 'AI match tools',
          title: widget.match.profile.displayName,
          subtitle:
              'Use your profiles to understand this match and prepare your next move.',
          stats: [
            PageBannerStat(
                icon: LucideIcons.sparkles,
                value: '${widget.match.matchScore}%',
                label: 'base match')
          ],
        ),
        const AiQuotaPanel(),
        if (_loading && _questionPreview.isNotEmpty)
          AppSurface(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(context.tr('Generating interview questions…')),
                for (final question in _questionPreview)
                  Text(Localizations.localeOf(context).languageCode == 'km' &&
                          question.questionKm.isNotEmpty
                      ? question.questionKm
                      : question.question),
              ])),
        Wrap(spacing: AppShape.space2, runSpacing: AppShape.space2, children: [
          _choice(_Tool.explanation, 'Why this match'),
          _choice(_Tool.gaps, 'Skill gaps'),
          _choice(_Tool.interview, 'Interview prep'),
        ]),
        if (_tool == _Tool.interview)
          AppInput(
              controller: _round,
              labelText: context.tr('Interview round (optional)'),
              hintText: context.tr('Technical round, HR interview…'),
              enabled: !_loading),
        if (!generated && !_loading && _error == null)
          AppSurface(
              child: Column(children: [
            Icon(_icon, size: 28, color: context.tokens.primary),
            const SizedBox(height: AppShape.space3),
            Text(_intro,
                textAlign: TextAlign.center,
                style: AppTypography.small
                    .copyWith(color: context.tokens.mutedForeground)),
          ])),
        if (_loading)
          AppSurface(
              child: Column(children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppShape.space3),
            Text(context.tr('Analyzing both profiles…'),
                style: AppTypography.small
                    .copyWith(color: context.tokens.mutedForeground)),
          ])),
        if (_error case final error?)
          PageState(
              variant: PageStateVariant.error,
              title: 'AI analysis could not finish',
              description:
                  error is ApiException ? error.message : 'Please try again.',
              actionLabel: 'Try again',
              onAction:
                  (ref.watch(aiQuotaProvider).valueOrNull?.exhausted() ?? false)
                      ? null
                      : _generate),
        if (!_loading && _error == null) ..._results(),
        if (_tool == _Tool.interview &&
            _questions != null &&
            !_loading &&
            _error == null)
          AppButton(
            label: 'Export interview prep PDF',
            icon: LucideIcons.fileDown,
            variant: AppButtonVariant.outline,
            loading: _exporting,
            onPressed: _exporting ? null : _exportInterviewPrep,
          ),
        if (!_loading && _error == null)
          AppButton(
              label: generated ? 'Generate again' : _buttonLabel,
              icon: LucideIcons.sparkles,
              fullWidth: true,
              variant: generated
                  ? AppButtonVariant.outline
                  : AppButtonVariant.primary,
              onPressed:
                  (ref.watch(aiQuotaProvider).valueOrNull?.exhausted() ?? false)
                      ? null
                      : _generate),
        Text(
            context.tr(
                'AI suggestions can be incomplete. Review them against the role and your own experience.'),
            textAlign: TextAlign.center,
            style: AppTypography.tiny
                .copyWith(color: context.tokens.mutedForeground)),
      ],
    );
  }

  Widget _choice(_Tool tool, String label) => ChoiceChip(
      label: Text(context.tr(label)),
      selected: _tool == tool,
      onSelected: _loading
          ? null
          : (_) => setState(() {
                _tool = tool;
                _error = null;
              }));

  List<Widget> _results() => switch (_tool) {
        _Tool.explanation when _explanation != null => [
            _ExplanationView(value: _explanation!)
          ],
        _Tool.gaps when _gaps != null => [_SkillGapView(value: _gaps!)],
        _Tool.interview when _questions != null => [
            _InterviewView(questions: _questions!)
          ],
        _ => const [],
      };

  IconData get _icon => switch (_tool) {
        _Tool.explanation => LucideIcons.badgeHelp,
        _Tool.gaps => LucideIcons.chartNoAxesCombined,
        _Tool.interview => LucideIcons.messagesSquare
      };
  String get _intro => switch (_tool) {
        _Tool.explanation =>
          'Get a detailed score, strengths, gaps, and a plain-language verdict.',
        _Tool.gaps =>
          'Compare your skills with open roles and get a prioritized learning plan.',
        _Tool.interview =>
          'Generate role-specific questions with English and Khmer answer guidance.'
      };
  String get _buttonLabel => switch (_tool) {
        _Tool.explanation => 'Explain this match',
        _Tool.gaps => 'Analyze skill gaps',
        _Tool.interview => 'Prepare interview'
      };
}

class _ExplanationView extends StatelessWidget {
  const _ExplanationView({required this.value});
  final AiMatchExplanation value;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppSurface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${value.score}% · ${value.verdict}',
              style:
                  AppTypography.h3.copyWith(color: context.tokens.foreground)),
          const SizedBox(height: AppShape.space2),
          Text(value.explanation,
              style: AppTypography.small
                  .copyWith(color: context.tokens.mutedForeground)),
        ])),
        const SizedBox(height: AppShape.space3),
        _ListCard(
            title: 'Strengths',
            icon: LucideIcons.circleCheck,
            items: value.strengths),
        const SizedBox(height: AppShape.space3),
        _ListCard(
            title: 'Areas to improve',
            icon: LucideIcons.circleAlert,
            items: value.gaps),
      ]);
}

class _SkillGapView extends StatelessWidget {
  const _SkillGapView({required this.value});
  final SkillGapAnalysis value;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppSurface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              context.tr("{0} GAP · ~{1} weeks", {
                '0': value.overallGap.toUpperCase(),
                '1': value.estimatedWeeks
              }),
              style: AppTypography.label
                  .copyWith(color: context.tokens.foreground)),
          if (value.topPriority.isNotEmpty) ...[
            const SizedBox(height: AppShape.space2),
            Text(value.topPriority,
                style: AppTypography.small
                    .copyWith(color: context.tokens.mutedForeground))
          ],
        ])),
        if (value.matchedSkills.isNotEmpty) ...[
          const SizedBox(height: AppShape.space3),
          _ListCard(
              title: 'Skills already matched',
              icon: LucideIcons.circleCheck,
              items: value.matchedSkills)
        ],
        for (final gap in value.missingSkills) ...[
          const SizedBox(height: AppShape.space3),
          AppSurface(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('${gap.skill} · ${gap.criticality}',
                    style: AppTypography.label
                        .copyWith(color: context.tokens.foreground)),
                if (gap.positions.isNotEmpty)
                  Text(gap.positions.join(', '),
                      style: AppTypography.tiny
                          .copyWith(color: context.tokens.mutedForeground)),
                const SizedBox(height: AppShape.space2),
                Text(gap.tip,
                    style: AppTypography.small
                        .copyWith(color: context.tokens.mutedForeground)),
              ]))
        ],
      ]);
}

class _InterviewView extends StatelessWidget {
  const _InterviewView({required this.questions});
  final List<InterviewQuestion> questions;
  @override
  Widget build(BuildContext context) => Column(children: [
        for (var i = 0; i < questions.length; i++)
          Padding(
              padding: const EdgeInsets.only(bottom: AppShape.space3),
              child: AppSurface(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('${i + 1}. ${questions[i].question}',
                        style: AppTypography.label
                            .copyWith(color: context.tokens.foreground)),
                    const SizedBox(height: AppShape.space2),
                    Text(questions[i].questionKm,
                        style: AppTypography.small
                            .copyWith(color: context.tokens.mutedForeground)),
                    const SizedBox(height: AppShape.space3),
                    Text(
                        context.tr(
                            "{0} · Answer tip", {'0': questions[i].category}),
                        style: AppTypography.tiny
                            .copyWith(color: context.tokens.primary)),
                    const SizedBox(height: AppShape.space1),
                    Text(questions[i].tip,
                        style: AppTypography.small
                            .copyWith(color: context.tokens.foreground)),
                    const SizedBox(height: AppShape.space2),
                    Text(questions[i].tipKm,
                        style: AppTypography.small
                            .copyWith(color: context.tokens.mutedForeground)),
                  ])))
      ]);
}

class _ListCard extends StatelessWidget {
  const _ListCard(
      {required this.title, required this.icon, required this.items});
  final String title;
  final IconData icon;
  final List<String> items;
  @override
  Widget build(BuildContext context) => AppSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style:
                AppTypography.label.copyWith(color: context.tokens.foreground)),
        for (final item in items)
          Padding(
              padding: const EdgeInsets.only(top: AppShape.space2),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(icon, size: 16, color: context.tokens.primary),
                const SizedBox(width: AppShape.space2),
                Expanded(
                    child: Text(item,
                        style: AppTypography.small
                            .copyWith(color: context.tokens.mutedForeground)))
              ])),
      ]));
}
