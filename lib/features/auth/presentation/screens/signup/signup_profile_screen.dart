import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/data/models/registration_request.dart';
import 'package:apsaratalent_mobile/features/auth/domain/constants/signup_options.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_message.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/step_header.dart';
import 'package:apsaratalent_mobile/features/auth/providers/signup/signup_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class SignupProfileScreen extends ConsumerStatefulWidget {
  const SignupProfileScreen({super.key});

  @override
  ConsumerState<SignupProfileScreen> createState() => _SignupProfileScreenState();
}

class _SignupProfileScreenState extends ConsumerState<SignupProfileScreen> {
  bool _submitted = false;

  // Shared
  String? _location;
  Set<String> _careerScopes = {};
  final _description = TextEditingController();

  // Employee
  final _firstname = TextEditingController();
  final _lastname = TextEditingController();
  final _username = TextEditingController();
  final _job = TextEditingController();
  String? _gender;
  DateTime? _dob;
  String? _experience;
  String? _availability;
  List<String> _skills = [];

  // Company
  final _companyName = TextEditingController();
  final _industry = TextEditingController();
  final _companySize = TextEditingController();
  final _website = TextEditingController();
  int? _foundedYear;
  String? _companyType;

  @override
  void dispose() {
    for (final c in [
      _description, _firstname, _lastname, _username, _job,
      _companyName, _industry, _companySize, _website,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String? _labelOf(List<SignupOption> options, String? value) {
    for (final o in options) {
      if (o.value == value) return o.label;
    }
    return null;
  }

  String? _required(String value, String field, {int? max}) {
    if (!_submitted) return null;
    final v = value.trim();
    if (v.isEmpty) return '$field is required';
    if (max != null && v.length > max) return '$field must be $max characters or fewer';
    return null;
  }

  String? _requiredChoice(Object? value, String field) =>
      _submitted && value == null ? 'Choose $field' : null;

  /* ------------------------------ Validation ------------------------------ */

  bool get _employeeValid =>
      _firstname.text.trim().isNotEmpty &&
      _firstname.text.trim().length <= 50 &&
      _lastname.text.trim().isNotEmpty &&
      _lastname.text.trim().length <= 50 &&
      _username.text.trim().isNotEmpty &&
      _gender != null &&
      _dob != null &&
      _location != null &&
      _job.text.trim().isNotEmpty &&
      _job.text.trim().length <= 50 &&
      _experience != null &&
      _availability != null &&
      _description.text.trim().isNotEmpty &&
      _description.text.trim().length <= 1000 &&
      _careerScopes.isNotEmpty &&
      _skills.isNotEmpty;

  int? get _sizeValue => int.tryParse(_companySize.text.trim());

  String? get _websiteError {
    final v = _website.text.trim();
    if (v.isEmpty) return null;
    final uri = Uri.tryParse(v);
    final ok = uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.contains('.');
    return ok || !_submitted ? null : 'Enter a full address, like https://example.com';
  }

  bool get _companyValid =>
      _companyName.text.trim().isNotEmpty &&
      _companyName.text.trim().length <= 20 &&
      _description.text.trim().isNotEmpty &&
      _description.text.trim().length <= 1000 &&
      _industry.text.trim().isNotEmpty &&
      _industry.text.trim().length <= 100 &&
      _location != null &&
      (_sizeValue ?? 0) > 0 &&
      _foundedYear != null &&
      _careerScopes.isNotEmpty &&
      (_website.text.trim().isEmpty ||
          (Uri.tryParse(_website.text.trim())?.host.contains('.') ?? false));

  /* -------------------------------- Submit -------------------------------- */

  Future<void> _submit() async {
    setState(() => _submitted = true);
    final signup = ref.read(signupProvider);
    final notifier = ref.read(signupProvider.notifier);
    final isEmployee = signup.role == ESignupRole.employee;

    if (isEmployee ? !_employeeValid : !_companyValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Some details are missing — check the highlighted fields.')),
      );
      return;
    }

    final ok = isEmployee
        ? await notifier.submitEmployee(EmployeeRegistration(
            email: signup.email,
            password: signup.password,
            phone: signup.phone,
            firstname: _firstname.text,
            lastname: _lastname.text,
            username: _username.text,
            gender: _gender!,
            dob: _dob!,
            location: _location!,
            job: _job.text,
            yearsOfExperience: _experience!,
            availability: _availability!,
            description: _description.text,
            careerScopes: _careerScopes.toList(),
            skills: _skills,
          ))
        : await notifier.submitCompany(CompanyRegistration(
            email: signup.email,
            password: signup.password,
            phone: signup.phone,
            name: _companyName.text,
            description: _description.text,
            industry: _industry.text,
            location: _location!,
            companySize: _sizeValue!,
            foundedYear: _foundedYear!,
            websiteUrl: _website.text,
            companyType: _companyType,
            careerScopes: _careerScopes.toList(),
          ));

    if (!ok || !mounted) return;
    final email = signup.email;
    // The account exists and is signed in; nothing entered here is needed any
    // more, the password least of all.
    notifier.reset();
    // Replace the stack: back from verification must not return to a signup
    // form for an account that already exists.
    context.router.replaceAll([EmailVerificationRoute(email: email, fromSignup: true)]);
  }

  /* -------------------------------- Pickers ------------------------------- */

  Future<void> _pickOne(
    String title,
    List<SignupOption> options,
    String? current,
    ValueChanged<String> onPicked,
  ) async {
    final picked = await showPickerSheet<String>(
      context,
      title: title,
      items: [for (final o in options) PickerItem(o.label, o.value)],
      selected: current,
    );
    if (picked != null) setState(() => onPicked(picked));
  }

  Future<void> _pickLocation() => _pickOne(
        'Location',
        [for (final l in SignupOptions.locations) SignupOption(l, l)],
        _location,
        (v) => _location = v,
      );

  Future<void> _pickCareerScopes() async {
    final picked = await showMultiPickerSheet<String>(
      context,
      title: 'Career scopes',
      items: [for (final c in SignupOptions.careerScopes) PickerItem(c, c)],
      selected: _careerScopes,
      max: 10,
    );
    if (picked != null) setState(() => _careerScopes = picked);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final latest = DateTime(now.year - 16, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      // Nobody under 16 signs up for a job-matching account.
      lastDate: latest,
      helpText: 'Date of birth',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickFoundedYear() async {
    final current = DateTime.now().year;
    final picked = await showPickerSheet<int>(
      context,
      title: 'Founded year',
      items: [
        for (var y = current; y >= SignupOptions.foundedYearMin; y--) PickerItem('$y', y),
      ],
      selected: _foundedYear,
    );
    if (picked != null) setState(() => _foundedYear = picked);
  }

  /* --------------------------------- Build -------------------------------- */

  @override
  Widget build(BuildContext context) {
    final signup = ref.watch(signupProvider);
    final isEmployee = signup.role == ESignupRole.employee;

    return AuthScaffold(
      showBack: true,
      showLogo: false,
      title: isEmployee ? 'About you' : 'About your company',
      subtitle: isEmployee
          ? 'Matching ranks roles against your career scopes and skills. You can '
              'add experience, education and your CV from your profile later.'
          : 'Matching ranks candidates against your career scopes. You can post '
              'open roles and add your logo from your profile later.',
      children: [
        const StepHeader(step: 3, total: 3),
        const SizedBox(height: AppShape.space5),
        ...(isEmployee ? _employeeFields() : _companyFields()),
        const SizedBox(height: AppShape.space4),
        _CareerScopes(
          selected: _careerScopes,
          errorText: _submitted && _careerScopes.isEmpty ? 'Choose at least one' : null,
          onEdit: _pickCareerScopes,
          onRemove: (c) => setState(() => _careerScopes = {..._careerScopes}..remove(c)),
        ),
        if (signup.flow.error != null) ...[
          const SizedBox(height: AppShape.space4),
          AuthMessage.error(_friendly(signup.flow.error!)),
        ],
        const SizedBox(height: AppShape.space6),
        AppButton(
          label: 'Create account',
          fullWidth: true,
          size: AppButtonSize.lg,
          loading: signup.flow.isLoading,
          onPressed: signup.flow.isLoading ? null : _submit,
        ),
      ],
    );
  }

  /// The API's duplicate message is "This credential already registered!",
  /// which doesn't say what to do next.
  static String _friendly(String error) =>
      error.toLowerCase().contains('already registered')
          ? 'An account with this email or phone already exists. Go back to '
              'log in, or use a different email.'
          : error;

  List<Widget> _employeeFields() => [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppInput(
                controller: _firstname,
                labelText: 'First name',
                hintText: 'First name',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
                errorText: _required(_firstname.text, 'First name', max: 50),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: AppShape.space2),
            Expanded(
              child: AppInput(
                controller: _lastname,
                labelText: 'Last name',
                hintText: 'Last name',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
                errorText: _required(_lastname.text, 'Last name', max: 50),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppShape.space4),
        AppInput(
          controller: _username,
          labelText: 'Username',
          hintText: 'How you appear to companies',
          prefixIcon: LucideIcons.atSign,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          errorText: _required(_username.text, 'Username', max: 50),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppShape.space4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppPickerField(
                labelText: 'Gender',
                hintText: 'Choose',
                value: _labelOf(SignupOptions.genders, _gender),
                errorText: _requiredChoice(_gender, 'gender'),
                onTap: () => _pickOne('Gender', SignupOptions.genders, _gender, (v) => _gender = v),
              ),
            ),
            const SizedBox(width: AppShape.space2),
            Expanded(
              child: AppPickerField(
                labelText: 'Date of birth',
                hintText: 'Choose',
                value: _dob == null ? null : MaterialLocalizations.of(context).formatShortDate(_dob!),
                errorText: _requiredChoice(_dob, 'a date'),
                onTap: _pickDob,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppShape.space4),
        AppPickerField(
          labelText: 'Location',
          hintText: 'Where you are based',
          prefixIcon: LucideIcons.mapPin,
          value: _location,
          errorText: _requiredChoice(_location, 'a location'),
          onTap: _pickLocation,
        ),
        const SizedBox(height: AppShape.space4),
        AppInput(
          controller: _job,
          labelText: 'Profession',
          hintText: 'e.g. Frontend Developer',
          prefixIcon: LucideIcons.briefcase,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.jobTitle],
          errorText: _required(_job.text, 'Profession', max: 50),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppShape.space4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppPickerField(
                labelText: 'Experience',
                hintText: 'Choose',
                value: _labelOf(SignupOptions.yearsOfExperience, _experience),
                errorText: _requiredChoice(_experience, 'one'),
                onTap: () => _pickOne('Years of experience', SignupOptions.yearsOfExperience,
                    _experience, (v) => _experience = v),
              ),
            ),
            const SizedBox(width: AppShape.space2),
            Expanded(
              child: AppPickerField(
                labelText: 'Availability',
                hintText: 'Choose',
                value: _labelOf(SignupOptions.availability, _availability),
                errorText: _requiredChoice(_availability, 'one'),
                onTap: () => _pickOne('Availability', SignupOptions.availability,
                    _availability, (v) => _availability = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppShape.space4),
        AppInput(
          controller: _description,
          labelText: 'About you',
          hintText: 'A few lines on what you do and what you are looking for',
          maxLines: 4,
          minLines: 3,
          errorText: _required(_description.text, 'A description', max: 1000),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppShape.space4),
        AppTagInput(
          labelText: 'Skills',
          hintText: 'e.g. React, then press +',
          tags: _skills,
          errorText: _submitted && _skills.isEmpty ? 'Add at least one skill' : null,
          onChanged: (v) => setState(() => _skills = v),
        ),
      ];

  List<Widget> _companyFields() => [
        AppInput(
          controller: _companyName,
          labelText: 'Company name',
          hintText: 'Company name',
          prefixIcon: LucideIcons.building2,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.organizationName],
          errorText: _required(_companyName.text, 'Company name', max: 20),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppShape.space4),
        AppInput(
          controller: _industry,
          labelText: 'Industry',
          hintText: 'e.g. Financial Services',
          prefixIcon: LucideIcons.factory,
          textInputAction: TextInputAction.next,
          errorText: _required(_industry.text, 'Industry', max: 100),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppShape.space4),
        AppPickerField(
          labelText: 'Location',
          hintText: 'Where the company is based',
          prefixIcon: LucideIcons.mapPin,
          value: _location,
          errorText: _requiredChoice(_location, 'a location'),
          onTap: _pickLocation,
        ),
        const SizedBox(height: AppShape.space4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppInput(
                controller: _companySize,
                labelText: 'Employees',
                hintText: 'e.g. 50',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                errorText: _submitted && (_sizeValue ?? 0) <= 0 ? 'Enter a number' : null,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: AppShape.space2),
            Expanded(
              child: AppPickerField(
                labelText: 'Founded',
                hintText: 'Year',
                value: _foundedYear?.toString(),
                errorText: _requiredChoice(_foundedYear, 'a year'),
                onTap: _pickFoundedYear,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppShape.space4),
        AppPickerField(
          labelText: 'Company type (optional)',
          hintText: 'Choose',
          value: _labelOf(SignupOptions.companyTypes, _companyType),
          onTap: () => _pickOne('Company type', SignupOptions.companyTypes, _companyType,
              (v) => _companyType = v),
        ),
        const SizedBox(height: AppShape.space4),
        AppInput(
          controller: _website,
          labelText: 'Website (optional)',
          hintText: 'https://example.com',
          prefixIcon: LucideIcons.globe,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.url],
          errorText: _websiteError,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppShape.space4),
        AppInput(
          controller: _description,
          labelText: 'About the company',
          hintText: 'What you do, and what it is like to work there',
          maxLines: 4,
          minLines: 3,
          errorText: _required(_description.text, 'A description', max: 1000),
          onChanged: (_) => setState(() {}),
        ),
      ];
}

class _CareerScopes extends StatelessWidget {
  const _CareerScopes({
    required this.selected,
    required this.onEdit,
    required this.onRemove,
    this.errorText,
  });

  final Set<String> selected;
  final VoidCallback onEdit;
  final ValueChanged<String> onRemove;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPickerField(
          labelText: 'Career scopes',
          hintText: 'The fields you work in',
          prefixIcon: LucideIcons.compass,
          value: selected.isEmpty ? null : '${selected.length} selected',
          errorText: errorText,
          onTap: onEdit,
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: AppShape.space2),
          Wrap(
            spacing: AppShape.space2,
            runSpacing: AppShape.space2,
            children: [
              for (final c in selected)
                InputChip(
                  label: Text(c, style: AppTypography.tag.copyWith(color: t.foreground)),
                  onDeleted: () => onRemove(c),
                  deleteIcon: Icon(LucideIcons.x, size: 14, color: t.mutedForeground),
                  deleteButtonTooltipMessage: 'Remove $c',
                ),
            ],
          ),
        ],
      ],
    );
  }
}
