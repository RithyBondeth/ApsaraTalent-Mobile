import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart'
    show humanize;
import 'package:apsaratalent_mobile/features/profile/domain/entities/profile_completion.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/presentation/widgets/profile_skeleton.dart';
import 'package:apsaratalent_mobile/features/profile/providers/profile_notifier.dart';
import 'package:apsaratalent_mobile/routes/app_route.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

/// The signed-in user's own profile: an employee record or a company record,
/// whichever the account has.
@RoutePage()
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return AppScreen(
      appBar: AppBar(title: const Text('Profile')),
      onRefresh: () async {
        try {
          await ref.read(profileProvider.notifier).refresh();
        } on ApiException catch (e) {
          if (context.mounted) _snack(context, e.message);
        }
      },
      children: profile.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const [ProfileSkeleton()],
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
        data: (profile) => profile == null
            ? const [
                PageState(
                  variant: PageStateVariant.empty,
                  icon: LucideIcons.userRound,
                  title: 'No profile on this account',
                  description:
                      'Profiles belong to talent and companies. Finish '
                      'signing up to get one.',
                ),
              ]
            : _content(context, profile),
      ),
    );
  }

  List<Widget> _content(BuildContext context, UserProfile profile) => [
        _Identity(profile: profile),
        _CompletionCard(completion: profile.completion),
        ...switch (profile) {
          EmployeeProfile() => _employee(profile),
          CompanyProfile() => _company(profile),
        },
        const SizedBox(height: AppShape.space2),
        AppButton(
          label: 'Edit profile',
          icon: LucideIcons.pencil,
          fullWidth: true,
          onPressed: () => context.router.push(const ProfileEditRoute()),
        ),
        const SizedBox(height: AppShape.space6),
      ];

  List<Widget> _employee(EmployeeProfile profile) => [
        if (profile.description case final bio?) ...[
          const SectionTitle(title: 'About'),
          AppSurface(child: _Body(text: bio)),
        ],
        if (profile.skills.isNotEmpty) ...[
          const SectionTitle(
            title: 'Skills',
            subtitle: 'What matching is ranked against',
          ),
          _Tags(labels: profile.skills),
        ],
        if (profile.careerScopes.isNotEmpty) ...[
          const SectionTitle(title: 'Career scopes'),
          _Tags(labels: profile.careerScopes),
        ],
        if (profile.experiences.isNotEmpty) ...[
          const SectionTitle(title: 'Work history'),
          for (final experience in profile.experiences)
            _Entry(title: experience.summary, body: experience.description),
        ],
        if (profile.educations.isNotEmpty) ...[
          const SectionTitle(title: 'Education'),
          for (final education in profile.educations)
            _Entry(title: education.summary, body: education.year),
        ],
        if (profile.languages.isNotEmpty) ...[
          const SectionTitle(title: 'Languages'),
          _Tags(labels: profile.languages, icon: LucideIcons.languages),
        ],
      ];

  List<Widget> _company(CompanyProfile profile) => [
        if (profile.description case final about?) ...[
          const SectionTitle(title: 'About'),
          AppSurface(child: _Body(text: about)),
        ],
        if (profile.openPositions.isNotEmpty) ...[
          const SectionTitle(
            title: 'Open positions',
            subtitle: 'What talent sees on your card',
          ),
          _Tags(labels: profile.openPositions),
        ],
        if (profile.careerScopes.isNotEmpty) ...[
          const SectionTitle(title: 'Career scopes'),
          _Tags(labels: profile.careerScopes),
        ],
        if (profile.benefits.isNotEmpty) ...[
          const SectionTitle(title: 'Benefits'),
          _Tags(labels: profile.benefits),
        ],
        if (profile.values.isNotEmpty) ...[
          const SectionTitle(title: 'Values'),
          _Tags(labels: profile.values),
        ],
      ];

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final availability = switch (profile) {
      EmployeeProfile(:final availability?) => humanize(availability),
      _ => null,
    };

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(
                name: profile.displayName,
                imageUrl: profile.avatarUrl,
                size: AppAvatarSize.xl,
              ),
              const SizedBox(width: AppShape.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: AppTypography.h4.copyWith(color: t.foreground),
                    ),
                    if (profile.headline case final headline?) ...[
                      const SizedBox(height: 2),
                      Text(
                        headline,
                        style: AppTypography.small.copyWith(
                          color: t.mutedForeground,
                        ),
                      ),
                    ],
                    if (profile.location case final location?) ...[
                      const SizedBox(height: AppShape.space2),
                      MetaChip(icon: LucideIcons.mapPin, label: location),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (availability != null) ...[
            const SizedBox(height: AppShape.space3),
            // Availability is categorical — a kind of arrangement, not a
            // severity. It must never render as a status pill.
            // Availability holds a mix: canonical employment types
            // (`full_time`) and older start-time values ("available",
            // "Immediately"). One categorical slot for all of them — the data
            // cannot support colour-coding a distinction between them.
            AppCategoryChip(
              category: AppCategory.brown,
              label: availability,
              icon: LucideIcons.circleDot,
            ),
          ],
        ],
      ),
    );
  }
}

/// How complete the profile is.
///
/// The bar is `primary` on `muted` rather than running green-to-red across the
/// range: completeness is a quantity, not a severity, and colouring a
/// half-filled profile amber would put it in the same visual language as a
/// failed application.
class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.completion});

  final ProfileCompletion completion;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Profile completion',
                  style: AppTypography.label.copyWith(color: t.foreground),
                ),
              ),
              Text(
                '${completion.percent}%',
                style: AppTypography.statValue.copyWith(
                  color: t.foreground,
                  fontSize: AppTypography.xl,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppShape.space3),
          Stack(
            children: [
              Container(height: 8, color: t.muted),
              FractionallySizedBox(
                widthFactor: completion.percent / 100,
                child: Container(height: 8, color: t.primary),
              ),
            ],
          ),
          const SizedBox(height: AppShape.space3),
          Text(
            // Named from the record rather than hardcoded, and heaviest first,
            // so the advice is worth following.
            completion.prompt ?? 'Your profile is complete.',
            style: AppTypography.tiny.copyWith(
              color: t.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({required this.labels, this.icon});

  final List<String> labels;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => AppSurface(
        child: Wrap(
          spacing: AppShape.space2,
          runSpacing: AppShape.space2,
          children: [
            for (final label in labels) AppTag(label: label, icon: icon),
          ],
        ),
      );
}

class _Entry extends StatelessWidget {
  const _Entry({required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space3),
      child: AppSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.label.copyWith(color: t.foreground),
            ),
            if (body case final body?) ...[
              const SizedBox(height: AppShape.space2),
              _Body(text: body),
            ],
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTypography.small.copyWith(
          color: context.tokens.mutedForeground,
          height: 1.45,
        ),
      );
}
