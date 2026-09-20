import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Whether the profile is saved, and whether an action on it is in flight.
typedef ProfileActionState = ({bool saved, bool busy});

/// Everything the screen already loaded about a profile, without leaving it.
///
/// There is no profile detail route on mobile yet, and the list response
/// already carries the full record, so this costs no request.
///
/// [actionState] is read with the sheet's own ref, so a save made here shows
/// on the card beneath. It is a callback rather than a provider because the
/// feed and the favourites screen keep this state in different notifiers —
/// reading one from the other would build a whole feed to show a bookmark.
///
/// [onLike] is null where liking is not offered, and its button is left out.
Future<void> showFeedProfileSheet(
  BuildContext context, {
  required FeedProfile profile,
  required ProfileActionState Function(WidgetRef ref) actionState,
  required Future<void> Function() onSave,
  Future<void> Function()? onLike,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, controller) => _Sheet(
        profile: profile,
        controller: controller,
        actionState: actionState,
        onSave: onSave,
        onLike: onLike,
      ),
    ),
  );
}

class _Sheet extends ConsumerWidget {
  const _Sheet({
    required this.profile,
    required this.controller,
    required this.actionState,
    required this.onSave,
    this.onLike,
  });

  final FeedProfile profile;
  final ScrollController controller;
  final ProfileActionState Function(WidgetRef ref) actionState;
  final Future<void> Function() onSave;
  final Future<void> Function()? onLike;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final profile = this.profile;
    final (:saved, :busy) = actionState(ref);

    return Column(
      children: [
        Container(height: AppShape.accentSurface, color: t.foreground),
        Expanded(
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(AppShape.screenPadding),
            children: [
              Row(
                children: [
                  AppAvatar(
                    imageUrl: profile.avatarUrl,
                    name: profile.displayName,
                    size: AppAvatarSize.xl,
                    squared: profile is FeedCompany,
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
                        if (_headline(profile) case final headline?)
                          Text(
                            headline,
                            style: AppTypography.small.copyWith(
                              color: t.mutedForeground,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppShape.space4),
              Wrap(
                spacing: AppShape.space3,
                runSpacing: AppShape.space2,
                children: [
                  for (final (icon, label) in _facts(profile))
                    MetaChip(icon: icon, label: label),
                ],
              ),
              ..._sections(context, profile),
              const SizedBox(height: AppShape.space6),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: t.card,
            border: Border(top: BorderSide(color: t.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppShape.screenPadding),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: saved ? 'Saved' : 'Save',
                    icon: saved
                        ? LucideIcons.bookmarkCheck
                        : LucideIcons.bookmark,
                    variant: AppButtonVariant.outline,
                    fullWidth: true,
                    onPressed: busy ? null : onSave,
                  ),
                ),
                if (onLike case final onLike?) ...[
                  const SizedBox(width: AppShape.space2),
                  Expanded(
                    child: AppButton(
                      label: 'Like',
                      icon: LucideIcons.heart,
                      fullWidth: true,
                      loading: busy,
                      onPressed: busy
                          ? null
                          : () async {
                              // A liked profile leaves the feed; so does its
                              // sheet.
                              Navigator.of(context).pop();
                              await onLike();
                            },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String? _headline(FeedProfile profile) => switch (profile) {
        FeedCompany(:final industry) => industry,
        FeedEmployee(:final job) => job,
      };

  static List<(IconData, String)> _facts(FeedProfile profile) =>
      switch (profile) {
        FeedCompany() => [
            if (profile.location != null) (LucideIcons.mapPin, profile.location!),
            if (profile.companySize != null)
              (LucideIcons.users, '${profile.companySize} people'),
            if (profile.foundedYear != null)
              (LucideIcons.calendar, 'Founded ${profile.foundedYear}'),
          ],
        FeedEmployee() => [
            if (profile.location != null) (LucideIcons.mapPin, profile.location!),
            if (profile.yearsOfExperience != null)
              (LucideIcons.briefcase, profile.yearsOfExperience!),
            if (profile.availability != null)
              (LucideIcons.clock, humanize(profile.availability!)),
          ],
      };

  static List<Widget> _sections(BuildContext context, FeedProfile profile) {
    final t = context.tokens;

    Widget heading(String title) => Padding(
          padding: const EdgeInsets.only(
            top: AppShape.space6,
            bottom: AppShape.space2,
          ),
          child: Text(
            title,
            style: AppTypography.label.copyWith(
              color: t.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

    Widget body(String text) => Text(
          text,
          style: AppTypography.small.copyWith(color: t.foreground, height: 1.5),
        );

    Widget tags(List<String> labels, {AppCategory? category}) => Wrap(
          spacing: AppShape.space2,
          runSpacing: AppShape.space2,
          children: [
            for (final label in labels)
              category == null
                  ? AppTag(label: label)
                  : AppCategoryChip(category: category, label: label),
          ],
        );

    Widget lines(List<String> items, IconData icon) => Column(
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppShape.space2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 16, color: t.mutedForeground),
                    const SizedBox(width: AppShape.space2),
                    Expanded(child: body(item)),
                  ],
                ),
              ),
          ],
        );

    return switch (profile) {
      FeedCompany() => [
          if (profile.description != null) ...[
            heading('About'),
            body(profile.description!),
          ],
          if (profile.openPositions.isNotEmpty) ...[
            heading('Open positions (${profile.openPositions.length})'),
            for (final position in profile.openPositions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppShape.space2),
                child: AppSurface(
                  elevation: SurfaceElevation.none,
                  padding: const EdgeInsets.all(AppShape.space3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position.title,
                        style: AppTypography.label.copyWith(
                          color: t.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppShape.space1),
                      Text(
                        [
                          if (position.type != null) humanize(position.type!),
                          if (position.salary != null) position.salary!,
                        ].join(' · '),
                        style: AppTypography.tiny.copyWith(
                          color: t.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          if (profile.benefits.isNotEmpty) ...[
            heading('Benefits'),
            tags(profile.benefits, category: AppCategory.pink),
          ],
          if (profile.values.isNotEmpty) ...[
            heading('Values'),
            tags(profile.values, category: AppCategory.gray),
          ],
          if (profile.careerScopes.isNotEmpty) ...[
            heading('Career scopes'),
            tags(profile.careerScopes),
          ],
        ],
      FeedEmployee() => [
          if (profile.description != null) ...[
            heading('About'),
            body(profile.description!),
          ],
          if (profile.skills.isNotEmpty) ...[
            heading('Skills'),
            tags(profile.skills),
          ],
          if (profile.experiences.isNotEmpty) ...[
            heading('Experience'),
            lines(profile.experiences, LucideIcons.briefcase),
          ],
          if (profile.educations.isNotEmpty) ...[
            heading('Education'),
            lines(profile.educations, LucideIcons.graduationCap),
          ],
          if (profile.careerScopes.isNotEmpty) ...[
            heading('Career scopes'),
            tags(profile.careerScopes),
          ],
        ],
    };
  }
}
