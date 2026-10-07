import 'package:flutter/material.dart';
import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

class ResumeDesignScreen extends StatefulWidget {
  const ResumeDesignScreen({super.key, required this.draft});
  final Map<String, dynamic> draft;
  @override
  State<ResumeDesignScreen> createState() => _ResumeDesignState();
}

class _ResumeDesignState extends State<ResumeDesignScreen> {
  static const options = <String, List<String>>{
    'layout': ['single', 'two-column', 'left-sidebar', 'right-sidebar'],
    'columnRatio': ['narrow', 'balanced', 'wide'],
    'headerLayout': ['stacked', 'split', 'centered', 'compact'],
    'avatarPlacement': ['start', 'center', 'end'],
    'palette': [
      'ocean',
      'cobalt',
      'violet',
      'emerald',
      'amber',
      'rose',
      'graphite',
      'midnight',
      'sand'
    ],
    'typography': ['sans', 'serif', 'geometric', 'humanist', 'mono'],
    'density': ['compact', 'balanced', 'spacious'],
    'headerStyle': ['solid', 'soft', 'minimal'],
    'sectionStyle': ['line', 'bar', 'pill', 'plain'],
    'cornerStyle': ['square', 'soft', 'rounded'],
    'experienceStyle': ['plain', 'cards', 'timeline'],
    'skillsStyle': ['chips', 'grid', 'list'],
    'educationStyle': ['plain', 'cards', 'timeline'],
    'summaryStyle': ['plain', 'highlight', 'quote'],
    'decoration': ['none', 'top-band', 'side-band', 'geometric'],
  };
  static const labels = {
    'layout': 'Layout',
    'columnRatio': 'Column width',
    'headerLayout': 'Header layout',
    'avatarPlacement': 'Photo position',
    'palette': 'Color palette',
    'typography': 'Typography',
    'density': 'Spacing',
    'headerStyle': 'Header style',
    'sectionStyle': 'Section headings',
    'cornerStyle': 'Corners',
    'experienceStyle': 'Experience style',
    'skillsStyle': 'Skills style',
    'educationStyle': 'Education style',
    'summaryStyle': 'Summary style',
    'decoration': 'Decoration',
  };
  late final Map<String, dynamic> _design = {
    for (final e in options.entries) e.key: e.value.first,
    'columnRatio': 'balanced',
    'density': 'balanced',
    'sidebarSections': ['skills', 'education'],
    ...?widget.draft['design'] as Map<String, dynamic>?,
  };
  late final _order = List<String>.from(widget.draft['sectionOrder'] ??
      ['summary', 'experience', 'skills', 'education', 'careerScopes']);
  late final _accent =
      TextEditingController(text: '${_design['customAccent'] ?? ''}');
  String? _error;
  @override
  void dispose() {
    _accent.dispose();
    super.dispose();
  }

  void _apply() {
    final accent = _accent.text.trim();
    if (accent.isNotEmpty && !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(accent)) {
      setState(() => _error = 'Use a color in #RRGGBB format.');
      return;
    }
    if (accent.isEmpty) {
      _design.remove('customAccent');
    } else {
      _design['customAccent'] = accent;
    }
    Navigator.pop(
        context, {...widget.draft, 'design': _design, 'sectionOrder': _order});
  }

  @override
  Widget build(BuildContext context) => AppScreen(
          appBar: AppBar(title: Text(context.tr('Resume design'))),
          children: [
            Text(context.tr(
                'Customize the design, then preview the PDF to see the result.')),
            for (final e in options.entries)
              Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                      initialValue: e.value.contains(_design[e.key])
                          ? _design[e.key] as String
                          : e.value.first,
                      decoration: InputDecoration(
                          labelText: context.tr(labels[e.key]!)),
                      items: [
                        for (final v in e.value)
                          DropdownMenuItem(value: v, child: Text(context.tr(v)))
                      ],
                      onChanged: (v) => setState(() => _design[e.key] = v))),
            TextField(
                controller: _accent,
                maxLength: 7,
                decoration: InputDecoration(
                    labelText: context.tr('Custom accent color'),
                    hintText: context.tr('#3366CC'))),
            SectionTitle(title: context.tr('Sidebar sections')),
            for (final section in [
              'summary',
              'skills',
              'education',
              'careerScopes'
            ])
              CheckboxListTile(
                  title: Text(context.tr(section)),
                  value: (_design['sidebarSections'] as List).contains(section),
                  onChanged: (v) => setState(() {
                        final sections =
                            List<String>.from(_design['sidebarSections']);
                        if (v == true) {
                          sections.add(section);
                        } else if (sections.length > 1) {
                          sections.remove(section);
                        }
                        _design['sidebarSections'] = sections;
                      })),
            SectionTitle(title: context.tr('Section order')),
            for (var i = 0; i < _order.length; i++)
              ListTile(
                  title: Text(context.tr(_order[i])),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        tooltip: context.tr('Move up'),
                        onPressed: i == 0
                            ? null
                            : () => setState(() {
                                  final v = _order.removeAt(i);
                                  _order.insert(i - 1, v);
                                }),
                        icon: const Icon(Icons.arrow_upward)),
                    IconButton(
                        tooltip: context.tr('Move down'),
                        onPressed: i == _order.length - 1
                            ? null
                            : () => setState(() {
                                  final v = _order.removeAt(i);
                                  _order.insert(i + 1, v);
                                }),
                        icon: const Icon(Icons.arrow_downward)),
                  ])),
            if (_error != null) Text(context.tr(_error!)),
            AppButton(label: 'Apply design', onPressed: _apply),
            TextButton(
                onPressed: () =>
                    Navigator.pop(context, {...widget.draft, 'design': null}),
                child: Text(context.tr('Use template design'))),
          ]);
}
