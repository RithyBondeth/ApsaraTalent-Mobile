import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

class ProfileCollectionsEditor extends StatefulWidget {
  const ProfileCollectionsEditor({
    super.key,
    required this.profile,
    required this.onChanged,
    this.careerScopeOptions = const [],
  });

  final UserProfile profile;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final List<String> careerScopeOptions;

  @override
  State<ProfileCollectionsEditor> createState() =>
      ProfileCollectionsEditorState();
}

class ProfileCollectionsEditorState extends State<ProfileCollectionsEditor> {
  late List<ProfileNamedItem> _skills;
  late List<ProfileNamedItem> _scopes;
  late Map<String, ProfileNamedItem> _originalSkills;
  late Map<String, ProfileNamedItem> _originalScopes;
  late List<ProfileExperience> _experiences;
  late List<ProfileEducation> _educations;
  late List<ProfileSocial> _socials;
  final _deletedSkills = <String>{};
  final _deletedScopes = <String>{};
  final _deletedExperiences = <String>{};
  final _deletedEducations = <String>{};
  final _deletedSocials = <String>{};

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _skills = profile is EmployeeProfile ? [...profile.skillItems] : [];
    _scopes = switch (profile) {
      EmployeeProfile() => [...profile.careerScopeItems],
      CompanyProfile() => [...profile.careerScopeItems],
    };
    _experiences = profile is EmployeeProfile ? [...profile.experiences] : [];
    _educations = profile is EmployeeProfile ? [...profile.educations] : [];
    _socials = switch (profile) {
      EmployeeProfile() => [...profile.socials],
      CompanyProfile() => [...profile.socials],
    };
    _originalSkills = {
      for (final item in _skills)
        if (item.name != null) item.name!: item,
    };
    _originalScopes = {
      for (final item in _scopes)
        if (item.name != null) item.name!: item,
    };
  }

  /// Merge reviewed import data into the current unsaved collections.
  void importResume(Map<String, dynamic> data) {
    if (data['skills'] is List) {
      _updateSkills({
        ..._skills.map((s) => s.name).whereType<String>(),
        ...List<String>.from(data['skills'])
      }.toList());
    }
    if (data['careerScopes'] is List) {
      _updateScopes({
        ..._scopes.map((s) => s.name).whereType<String>(),
        ...List<String>.from(data['careerScopes'])
      }.toList());
    }
    setState(() {
      for (final row
          in List<Map<String, dynamic>>.from(data['experiences'] ?? [])) {
        if (!_experiences.any((e) =>
            e.title == row['title'] &&
            e.company == row['company'] &&
            (e.startDate ?? '').split('T').first == (row['startDate'] ?? ''))) {
          _experiences.add(ProfileExperience.fromJson(row));
        }
      }
      for (final row
          in List<Map<String, dynamic>>.from(data['educations'] ?? [])) {
        if (!_educations.any((e) =>
            e.school == row['school'] &&
            e.degree == row['degree'] &&
            e.year == row['year'])) {
          _educations.add(ProfileEducation.fromJson(row));
        }
      }
    });
    if (data.containsKey('experiences')) {
      _emit('experiences', _experiences.map((e) => e.toJson()).toList(),
          'experienceIdsToDelete', _deletedExperiences);
    }
    if (data.containsKey('educations')) {
      _emit('educations', _educations.map((e) => e.toJson()).toList(),
          'educationIdsToDelete', _deletedEducations);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.profile is EmployeeProfile) ...[
            const SectionTitle(
              title: 'Skills',
              subtitle: 'Used for recommendations and matching',
            ),
            AppTagInput(
              tags:
                  _skills.map((item) => item.name).whereType<String>().toList(),
              hintText: 'Add a skill',
              onChanged: _updateSkills,
            ),
            const SectionTitle(title: 'Work history'),
            _records(
              empty: 'No work history yet.',
              addLabel: 'Add experience',
              items: [
                for (var i = 0; i < _experiences.length; i++)
                  _record(
                    title: _experiences[i].summary,
                    subtitle: _experiences[i].description,
                    onEdit: () => _editExperience(i),
                    onRemove: () => _removeExperience(i),
                  ),
              ],
              onAdd: () => _editExperience(null),
            ),
            const SectionTitle(title: 'Education'),
            _records(
              empty: 'No education yet.',
              addLabel: 'Add education',
              items: [
                for (var i = 0; i < _educations.length; i++)
                  _record(
                    title: _educations[i].summary,
                    subtitle: _educations[i].year,
                    onEdit: () => _editEducation(i),
                    onRemove: () => _removeEducation(i),
                  ),
              ],
              onAdd: () => _editEducation(null),
            ),
          ],
          const SectionTitle(
            title: 'Career scopes',
            subtitle: 'The work areas this profile belongs to',
          ),
          AppTagInput(
            tags: _scopes.map((item) => item.name).whereType<String>().toList(),
            hintText: 'Add a career scope',
            onChanged: _updateScopes,
          ),
          if (widget.careerScopeOptions.isNotEmpty)
            TextButton.icon(
              onPressed: _chooseCatalogScopes,
              icon: const Icon(LucideIcons.listChecks),
              label: const Text('Choose from career-scope catalog'),
            ),
          const SectionTitle(title: 'Social links'),
          _records(
            empty: 'No social links yet.',
            addLabel: 'Add social link',
            items: [
              for (var i = 0; i < _socials.length; i++)
                _record(
                  title: _socials[i].platform ?? 'Link',
                  subtitle: _socials[i].url,
                  onEdit: () => _editSocial(i),
                  onRemove: () => _removeSocial(i),
                ),
            ],
            onAdd: () => _editSocial(null),
          ),
        ],
      );

  Widget _records({
    required String empty,
    required String addLabel,
    required List<Widget> items,
    required VoidCallback onAdd,
  }) =>
      AppSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppShape.space3),
                child: Text(empty),
              )
            else
              ...items,
            AppButton(
              label: addLabel,
              icon: LucideIcons.plus,
              size: AppButtonSize.sm,
              variant: AppButtonVariant.outline,
              onPressed: onAdd,
            ),
          ],
        ),
      );

  Widget _record({
    required String title,
    String? subtitle,
    required VoidCallback onEdit,
    required VoidCallback onRemove,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: AppShape.space3),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.isEmpty ? 'Untitled' : title),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(subtitle,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(LucideIcons.pencil, size: 18),
            ),
            IconButton(
              tooltip: 'Remove',
              onPressed: onRemove,
              icon: const Icon(LucideIcons.trash2, size: 18),
            ),
          ],
        ),
      );

  void _updateSkills(List<String> names) {
    setState(() =>
        _skills = _mergeNames(_skills, names, _deletedSkills, _originalSkills));
    _emit('skills', _skills.map((item) => item.toJson()).toList(),
        'skillIdsToDelete', _deletedSkills);
  }

  void _updateScopes(List<String> names) {
    setState(() =>
        _scopes = _mergeNames(_scopes, names, _deletedScopes, _originalScopes));
    _emit('careerScopes', _scopes.map((item) => item.toJson()).toList(),
        'careerScopeIdsToDelete', _deletedScopes);
  }

  Future<void> _chooseCatalogScopes() async {
    if (widget.careerScopeOptions.isEmpty) return;
    final picked = await showMultiPickerSheet<String>(
      context,
      title: 'Career scopes',
      items: [
        for (final name in widget.careerScopeOptions) PickerItem(name, name)
      ],
      selected: _scopes.map((item) => item.name).whereType<String>().toSet(),
      max: 10,
    );
    if (picked != null) _updateScopes(picked.toList());
  }

  List<ProfileNamedItem> _mergeNames(
    List<ProfileNamedItem> current,
    List<String> names,
    Set<String> deleted,
    Map<String, ProfileNamedItem> original,
  ) {
    final byName = {for (final item in current) item.name: item};
    for (final item in current) {
      if (!names.contains(item.name) && item.id != null) deleted.add(item.id!);
    }
    return [
      for (final name in names)
        (() {
          final item =
              byName[name] ?? original[name] ?? ProfileNamedItem(name: name);
          if (item.id != null) deleted.remove(item.id);
          return item;
        })(),
    ];
  }

  Future<void> _editExperience(int? index) async {
    final old = index == null ? null : _experiences[index];
    final values = await _editFields('Experience', [
      ('Job title', old?.title ?? '', false),
      ('Company', old?.company ?? '', false),
      ('Description', old?.description ?? '', true),
      ('Start date (YYYY-MM-DD)', _date(old?.startDate), false),
      ('End date (YYYY-MM-DD)', _date(old?.endDate), false),
    ]);
    if (values == null || values[0].trim().isEmpty) return;
    final item = ProfileExperience(
      id: old?.id,
      title: values[0].trim(),
      company: _nullIfBlank(values[1]),
      description: _nullIfBlank(values[2]),
      startDate: _isoDate(values[3]),
      endDate: _isoDate(values[4]),
    );
    setState(() =>
        index == null ? _experiences.add(item) : _experiences[index] = item);
    _emit('experiences', _experiences.map((item) => item.toJson()).toList(),
        'experienceIdsToDelete', _deletedExperiences);
  }

  void _removeExperience(int index) {
    final item = _experiences[index];
    if (item.id != null) _deletedExperiences.add(item.id!);
    setState(() => _experiences.removeAt(index));
    _emit('experiences', _experiences.map((item) => item.toJson()).toList(),
        'experienceIdsToDelete', _deletedExperiences);
  }

  Future<void> _editEducation(int? index) async {
    final old = index == null ? null : _educations[index];
    final values = await _editFields('Education', [
      ('School', old?.school ?? '', false),
      ('Degree', old?.degree ?? '', false),
      ('Year', old?.year ?? '', false),
    ]);
    if (values == null ||
        (values[0].trim().isEmpty && values[1].trim().isEmpty)) {
      return;
    }
    final item = ProfileEducation(
      id: old?.id,
      school: _nullIfBlank(values[0]),
      degree: _nullIfBlank(values[1]),
      year: _nullIfBlank(values[2]),
    );
    setState(() =>
        index == null ? _educations.add(item) : _educations[index] = item);
    _emit('educations', _educations.map((item) => item.toJson()).toList(),
        'educationIdsToDelete', _deletedEducations);
  }

  void _removeEducation(int index) {
    final item = _educations[index];
    if (item.id != null) _deletedEducations.add(item.id!);
    setState(() => _educations.removeAt(index));
    _emit('educations', _educations.map((item) => item.toJson()).toList(),
        'educationIdsToDelete', _deletedEducations);
  }

  Future<void> _editSocial(int? index) async {
    final old = index == null ? null : _socials[index];
    final values = await _editFields('Social link', [
      ('Platform', old?.platform ?? '', false),
      ('URL', old?.url ?? '', false),
    ]);
    if (values == null || values[1].trim().isEmpty) return;
    final item = ProfileSocial(
      id: old?.id,
      platform: _nullIfBlank(values[0]),
      url: values[1].trim(),
    );
    setState(() => index == null ? _socials.add(item) : _socials[index] = item);
    _emit('socials', _socials.map((item) => item.toJson()).toList(),
        'socialIdsToDelete', _deletedSocials);
  }

  void _removeSocial(int index) {
    final item = _socials[index];
    if (item.id != null) _deletedSocials.add(item.id!);
    setState(() => _socials.removeAt(index));
    _emit('socials', _socials.map((item) => item.toJson()).toList(),
        'socialIdsToDelete', _deletedSocials);
  }

  void _emit(String key, List<Map<String, dynamic>> items, String deleteKey,
      Set<String> deleted) {
    widget.onChanged({
      key: items,
      if (deleted.isNotEmpty) deleteKey: deleted.toList(),
    });
  }

  Future<List<String>?> _editFields(
    String title,
    List<(String, String, bool)> fields,
  ) async {
    final controllers = [
      for (final field in fields) TextEditingController(text: field.$2),
    ];
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < fields.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppShape.space3),
                  child: TextField(
                    controller: controllers[i],
                    maxLines: fields[i].$3 ? 4 : 1,
                    decoration: InputDecoration(labelText: fields[i].$1),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              controllers.map((controller) => controller.text).toList(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    for (final controller in controllers) {
      controller.dispose();
    }
    return result;
  }

  String? _nullIfBlank(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _date(String? value) =>
      value == null || value.length < 10 ? '' : value.substring(0, 10);

  String? _isoDate(String value) {
    final parsed = DateTime.tryParse(value.trim());
    return parsed?.toUtc().toIso8601String();
  }
}
