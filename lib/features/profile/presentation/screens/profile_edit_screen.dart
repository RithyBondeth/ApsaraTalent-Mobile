import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/auth/domain/constants/signup_options.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/providers/profile_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// Editing the profile's own fields.
///
/// Only what changed is sent: the API applies the keys it receives and leaves
/// the rest alone, so an untouched field is never written back.
///
/// Three things are deliberately absent.
///
/// **Email.** Changing it sets `isEmailVerified` back to false server-side,
/// which would silently drop someone into the unverified state from a screen
/// that says nothing about verification. It belongs with the verification
/// flow, not here.
///
/// **Photos, résumé and cover letter.** Those are multipart upload routes and
/// the app has no file picker dependency.
///
/// **Skills, education, work history, career scopes and socials.** The update
/// endpoint takes them as nested collections with their own delete lists —
/// a list editor per collection, which is its own screen.
@RoutePage()
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _fields = <String, TextEditingController>{};
  final _picked = <String, String?>{};
  List<String>? _languages;
  bool _saving = false;
  UserProfile? _loaded;

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Seeds the controllers once, from whatever the profile held when the
  /// screen opened. A later refresh must not overwrite what is being typed.
  void _seed(UserProfile profile) {
    if (_loaded != null) return;
    _loaded = profile;

    void text(String key, String? value) =>
        _fields[key] = TextEditingController(text: value ?? '');

    switch (profile) {
      case EmployeeProfile():
        text('firstname', profile.firstName);
        text('lastname', profile.lastName);
        text('username', profile.username);
        text('job', profile.job);
        text('description', profile.description);
        text('phone', profile.phone);
        text('portfolioUrl', profile.portfolioUrl);
        text('linkedinUrl', profile.linkedinUrl);
        _picked['gender'] = profile.gender;
        _picked['location'] = profile.location;
        _picked['yearsOfExperience'] = profile.yearsOfExperience;
        _picked['availability'] = profile.availability;
        _picked['workMode'] = profile.workMode;
        _picked['noticePeriod'] = profile.noticePeriod;
        _languages = [...profile.languages];
      case CompanyProfile():
        text('name', profile.name);
        text('industry', profile.industry);
        text('description', profile.description);
        text('phone', profile.phone);
        text('companySize', profile.companySize?.toString());
        text('foundedYear', profile.foundedYear?.toString());
        _picked['location'] = profile.location;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return AppScreen(
      appBar: AppBar(title: const Text('Edit profile')),
      children: profile.when(
        loading: () => const [ProfileEditSkeleton()],
        error: (error, _) => [
          PageState(
            variant: PageStateVariant.error,
            title: 'Your profile could not load',
            description: error is ApiException
                ? error.message
                : 'Check your connection and try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(profileProvider),
          ),
        ],
        data: (profile) {
          if (profile == null) {
            return const [
              PageState(
                variant: PageStateVariant.empty,
                icon: LucideIcons.userRound,
                title: 'No profile on this account',
                description: 'Profiles belong to talent and companies.',
              ),
            ];
          }
          _seed(profile);
          return switch (profile) {
            EmployeeProfile() => _employeeForm(),
            CompanyProfile() => _companyForm(),
          };
        },
      ),
    );
  }

  List<Widget> _employeeForm() => [
        const SectionTitle(title: 'You'),
        _text('firstname', 'First name'),
        _text('lastname', 'Last name'),
        _text('username', 'Username'),
        _pick('gender', 'Gender', SignupOptions.genders),
        _pick(
          'location',
          'Location',
          [for (final l in SignupOptions.locations) SignupOption(l, l)],
        ),
        _text('phone', 'Phone'),
        const SectionTitle(title: 'Work'),
        _text('job', 'Job title'),
        _pick(
          'yearsOfExperience',
          'Years of experience',
          SignupOptions.yearsOfExperience,
        ),
        _pick('availability', 'Availability', SignupOptions.availability),
        _pick('workMode', 'Work mode', SignupOptions.workModes),
        _pick('noticePeriod', 'Notice period', SignupOptions.noticePeriods),
        const SectionTitle(title: 'About'),
        _text('description', 'Bio', maxLines: 5),
        const SectionTitle(title: 'Links'),
        _text('portfolioUrl', 'Portfolio URL'),
        _text('linkedinUrl', 'LinkedIn URL'),
        const SectionTitle(title: 'Languages'),
        AppTagInput(
          tags: _languages ?? const [],
          hintText: 'Add a language',
          onChanged: (tags) => setState(() => _languages = tags),
        ),
        ..._footer(),
      ];

  List<Widget> _companyForm() => [
        const SectionTitle(title: 'Company'),
        _text('name', 'Company name'),
        _text('industry', 'Industry'),
        _pick(
          'location',
          'Location',
          [for (final l in SignupOptions.locations) SignupOption(l, l)],
        ),
        _text('phone', 'Phone'),
        const SectionTitle(title: 'Details'),
        _text('companySize', 'Company size', keyboard: TextInputType.number),
        _text('foundedYear', 'Founded year', keyboard: TextInputType.number),
        const SectionTitle(title: 'About'),
        _text('description', 'Description', maxLines: 5),
        ..._footer(),
      ];

  List<Widget> _footer() => [
        const SizedBox(height: AppShape.space2),
        AppButton(
          label: 'Save changes',
          icon: LucideIcons.check,
          fullWidth: true,
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppShape.space2),
          child: Text(
            // Says what this screen cannot do, rather than leaving someone
            // hunting for it.
            'Photos, résumé and email are not editable here yet.',
            textAlign: TextAlign.center,
            style: AppTypography.tiny.copyWith(
              color: context.tokens.mutedForeground,
            ),
          ),
        ),
        const SizedBox(height: AppShape.space6),
      ];

  Widget _text(
    String key,
    String label, {
    int maxLines = 1,
    TextInputType? keyboard,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: AppShape.space3),
        child: AppInput(
          controller: _fields[key],
          labelText: label,
          hintText: label,
          maxLines: maxLines,
          keyboardType: keyboard,
        ),
      );

  Widget _pick(String key, String label, List<SignupOption> options) {
    final value = _picked[key];
    final match = options.where((o) => o.value == value).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space3),
      child: AppPickerField(
        labelText: label,
        hintText: label,
        // A stored value outside the option list still shows, rather than
        // reading as empty — `availability` in particular holds older values
        // no current option offers.
        value: match.isNotEmpty ? match.first.label : value,
        onTap: () async {
          final picked = await showPickerSheet<String>(
            context,
            title: label,
            items: [for (final o in options) PickerItem(o.label, o.value)],
            selected: value,
          );
          if (picked != null) setState(() => _picked[key] = picked);
        },
      ),
    );
  }

  /// Everything the reader actually changed, and nothing else.
  Map<String, dynamic> get _changes {
    final profile = _loaded;
    if (profile == null) return const {};
    final changes = <String, dynamic>{};

    void compare(String key, String? original) {
      final now = _fields[key]?.text.trim();
      if (now == null) return;
      final before = original?.trim() ?? '';
      if (now == before) return;
      // An emptied field clears it; the API takes null for these.
      changes[key] = now.isEmpty ? null : now;
    }

    void compareInt(String key, int? original) {
      final now = _fields[key]?.text.trim();
      if (now == null) return;
      final parsed = now.isEmpty ? null : int.tryParse(now);
      if (parsed == original) return;
      changes[key] = parsed;
    }

    void comparePick(String key, String? original) {
      final now = _picked[key];
      if (now != original) changes[key] = now;
    }

    switch (profile) {
      case EmployeeProfile():
        compare('firstname', profile.firstName);
        compare('lastname', profile.lastName);
        compare('username', profile.username);
        compare('job', profile.job);
        compare('description', profile.description);
        compare('phone', profile.phone);
        compare('portfolioUrl', profile.portfolioUrl);
        compare('linkedinUrl', profile.linkedinUrl);
        comparePick('gender', profile.gender);
        comparePick('location', profile.location);
        comparePick('yearsOfExperience', profile.yearsOfExperience);
        comparePick('availability', profile.availability);
        comparePick('workMode', profile.workMode);
        comparePick('noticePeriod', profile.noticePeriod);
        final languages = _languages ?? const <String>[];
        if (!_sameList(languages, profile.languages)) {
          changes['languages'] = languages;
        }
      case CompanyProfile():
        compare('name', profile.name);
        compare('industry', profile.industry);
        compare('description', profile.description);
        compare('phone', profile.phone);
        comparePick('location', profile.location);
        compareInt('companySize', profile.companySize);
        compareInt('foundedYear', profile.foundedYear);
    }
    return changes;
  }

  static bool _sameList(List<String> a, List<String> b) =>
      a.length == b.length &&
      [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((same) => same);

  Future<void> _save() async {
    final changes = _changes;
    if (changes.isEmpty) {
      _snack('Nothing changed.');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(profileProvider.notifier).save(changes);
      if (!mounted) return;
      _snack('Profile saved.');
      context.router.maybePop();
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class ProfileEditSkeleton extends StatelessWidget {
  const ProfileEditSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (var i = 0; i < 4; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: AppShape.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 90, height: 10),
                  SizedBox(height: AppShape.space2),
                  AppSkeleton(height: 44),
                ],
              ),
            ),
        ],
      );
}
