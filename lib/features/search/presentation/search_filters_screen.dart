import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:flutter/material.dart';

/// Uses the gateway's query keys so a saved search behaves identically on web.
class SearchFiltersScreen extends StatefulWidget {
  const SearchFiltersScreen(
      {super.key, required this.jobs, required this.filters});
  final bool jobs;
  final Map<String, dynamic> filters;
  @override
  State<SearchFiltersScreen> createState() => _SearchFiltersScreenState();
}

class _SearchFiltersScreenState extends State<SearchFiltersScreen> {
  final _form = GlobalKey<FormState>();
  late final Map<String, dynamic> _values = {...widget.filters};
  final _controllers = <String, TextEditingController>{};
  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _set(String key, dynamic value) {
    if (value == null || value == '' || (value is List && value.isEmpty)) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  Widget _choice(String label, String key, Map<String, String> choices) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: DropdownButtonFormField<String>(
            key: ValueKey('$key:${_values[key]}'),
            initialValue:
                choices.containsKey(_values[key]) ? _values[key] as String : '',
            decoration: InputDecoration(labelText: context.tr(label)),
            items: [
              DropdownMenuItem(value: '', child: Text(context.tr('All'))),
              for (final entry in choices.entries)
                DropdownMenuItem(
                    value: entry.key, child: Text(context.tr(entry.value)))
            ],
            onChanged: (value) => setState(() => _set(key, value)),
          ));
  Widget _text(String label, String key,
      {bool number = false,
      bool integer = false,
      String? upperKey,
      bool list = false}) {
    final controller = _controllers.putIfAbsent(
        key,
        () => TextEditingController(
            text: _values[key] is List
                ? (_values[key] as List).join(', ')
                : '${_values[key] ?? ''}'));
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: context.tr(label)),
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          validator: (value) {
            if (!number || value!.trim().isEmpty) return null;
            final parsed = num.tryParse(value.trim());
            if (parsed == null ||
                !parsed.isFinite ||
                parsed < 0 ||
                (integer && parsed != parsed.round())) {
              return context.tr('Enter a valid non-negative number.');
            }
            final upper = _values[upperKey];
            if (upper is num && parsed > upper) {
              return context.tr('Minimum cannot exceed maximum.');
            }
            return null;
          },
          onChanged: (value) => _set(
              key,
              list
                  ? value
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toSet()
                      .toList()
                  : number
                      ? num.tryParse(value.trim())
                      : value.trim()),
        ));
  }

  Widget _date(String label, String key) => TextFormField(
      key: ValueKey('$key:${_values[key]}'),
      readOnly: true,
      initialValue: '${_values[key] ?? ''}'.split('T').first,
      decoration: InputDecoration(
          labelText: context.tr(label),
          suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() => _values.remove(key)))),
      validator: (_) {
        final from = DateTime.tryParse('${_values['postedDateFrom']}');
        final to = DateTime.tryParse('${_values['postedDateTo']}');
        return from != null && to != null && from.isAfter(to)
            ? context.tr('Start date cannot follow end date.')
            : null;
      },
      onTap: () async {
        final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.tryParse('${_values[key]}')?.toLocal() ??
                DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100));
        if (picked != null && mounted) {
          setState(() => _set(
              key,
              (key == 'postedDateTo'
                      ? DateTime(picked.year, picked.month, picked.day, 23, 59,
                          59, 999)
                      : picked)
                  .toUtc()
                  .toIso8601String()));
        }
      });
  @override
  Widget build(BuildContext context) {
    final educationKey = widget.jobs ? 'educationRequired' : 'education';
    final education = _values[educationKey] is List
        ? List<String>.from(_values[educationKey])
        : _values[educationKey] is String
            ? [_values[educationKey] as String]
            : <String>[];
    final sort =
        '${_values['sortBy'] ?? 'relevance'}-${_values['sortOrder'] ?? 'DESC'}';
    final sortChoices = {
      'relevance-DESC': 'Best match',
      'createdAt-DESC': 'Newest first',
      'createdAt-ASC': 'Oldest first',
      if (widget.jobs) 'companySize-DESC': 'Company size: high to low',
      if (widget.jobs) 'companySize-ASC': 'Company size: low to high',
      if (!widget.jobs) 'yearsOfExperience-DESC': 'Experience: high to low',
      if (!widget.jobs) 'yearsOfExperience-ASC': 'Experience: low to high'
    };
    return AppScreen(
        appBar: AppBar(title: Text(context.tr('Search filters'))),
        children: [
          Form(
              key: _form,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _text('Location', 'location'),
                    _choice('Job type', 'jobType', {
                      'full_time': 'Full time',
                      'part_time': 'Part time',
                      'internship': 'Internship',
                      'contract': 'Contract',
                      'freelance': 'Freelance'
                    }),
                    _choice('Experience level', 'experienceLevel', {
                      for (final value in [
                        'No Experience',
                        'Less than 1 year',
                        '1 - 2 years',
                        '3 - 5 years',
                        '6 - 10 years',
                        '10+ years'
                      ])
                        value: value
                    }),
                    Text(context.tr('Education')),
                    for (final value in [
                      'Under Graduate',
                      'Bachelor',
                      'Master',
                      'PhD'
                    ])
                      CheckboxListTile(
                          title: Text(context.tr(value)),
                          value: education.contains(value),
                          onChanged: (checked) => setState(() {
                                if (checked == true) {
                                  education.add(value);
                                } else {
                                  education.remove(value);
                                }
                                _set(educationKey, education);
                              })),
                    if (!widget.jobs)
                      _text('Skills (comma separated)', 'skills', list: true),
                    if (widget.jobs) ...[
                      _choice('Work mode', 'workMode', {
                        'remote': 'Remote',
                        'on_site': 'On site',
                        'hybrid': 'Hybrid',
                        'flexible': 'Flexible'
                      }),
                      _text('Minimum company size', 'companySizeMin',
                          number: true,
                          integer: true,
                          upperKey: 'companySizeMax'),
                      _text('Maximum company size', 'companySizeMax',
                          number: true, integer: true),
                      _text('Minimum salary', 'salaryMin',
                          number: true, upperKey: 'salaryMax'),
                      _text('Maximum salary', 'salaryMax', number: true),
                      _date('Posted from', 'postedDateFrom'),
                      _date('Posted to', 'postedDateTo'),
                    ],
                    DropdownButtonFormField<String>(
                        key: ValueKey('sort:$sort'),
                        initialValue: sortChoices.containsKey(sort)
                            ? sort
                            : 'relevance-DESC',
                        decoration:
                            InputDecoration(labelText: context.tr('Sort by')),
                        items: [
                          for (final entry in sortChoices.entries)
                            DropdownMenuItem(
                                value: entry.key,
                                child: Text(context.tr(entry.value)))
                        ],
                        onChanged: (value) => setState(() {
                              final parts = value!.split('-');
                              _values['sortBy'] = parts[0];
                              _values['sortOrder'] = parts[1];
                            })),
                    const SizedBox(height: 16),
                    AppButton(
                        label: 'Apply filters',
                        onPressed: () {
                          if (_form.currentState!.validate()) {
                            Navigator.of(context)
                                .pop(Map<String, dynamic>.from(_values));
                          }
                        }),
                    AppButton(
                        label: 'Reset filters',
                        variant: AppButtonVariant.outline,
                        onPressed: () {
                          Navigator.of(context).pop(<String, dynamic>{});
                        }),
                  ])),
        ]);
  }
}
