import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A company or an employee in the feed, with the two actions the web card
/// has: save for later, and like.
///
/// Open positions and skills are neutral tags; benefits take the pink
/// categorical slot, as on the web. Nothing else on the card is coloured.
class FeedProfileCard extends StatelessWidget {
  const FeedProfileCard({
    super.key,
    required this.profile,
    required this.saved,
    required this.busy,
    required this.onTap,
    required this.onSave,
    this.onLike,
    required this.onView,
    this.recommended = false,
  });

  final FeedProfile profile;
  final bool saved;

  /// A like or save for this profile is in flight.
  final bool busy;
  final bool recommended;
  final VoidCallback onTap;
  final VoidCallback onSave;

  /// Null on the favourites screen, which offers no like — as the web's
  /// favourite card does not. The button is left out rather than disabled.
  final VoidCallback? onLike;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final profile = this.profile;

    return AppSurface(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recommended) ...[
            Row(
              children: [
                Icon(LucideIcons.sparkles, size: 12, color: t.mutedForeground),
                const SizedBox(width: AppShape.space1),
                Text(
                  'RECOMMENDED',
                  style: AppTypography.eyebrow.copyWith(
                    color: t.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppShape.space3),
          ],
          _Identity(profile: profile),
          if (_summary(profile) case final summary?) ...[
            const SizedBox(height: AppShape.space3),
            Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.small.copyWith(
                color: t.mutedForeground,
                height: 1.45,
              ),
            ),
          ],
          ..._chips(profile),
          const SizedBox(height: AppShape.space3),
          Divider(color: t.border, height: AppShape.hairline),
          const SizedBox(height: AppShape.space3),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: saved ? 'Saved' : 'Save',
                      icon: saved
                          ? LucideIcons.bookmarkCheck
                          : LucideIcons.bookmark,
                      variant: AppButtonVariant.outline,
                      size: AppButtonSize.sm,
                      fullWidth: true,
                      onPressed: busy ? null : onSave,
                    ),
                  ),
                  if (onLike case final onLike?) ...[
                    const SizedBox(width: AppShape.space2),
                    Expanded(
                      child: AppButton(
                        label: 'Like',
                        variant: AppButtonVariant.outline,
                        icon: LucideIcons.heart,
                        size: AppButtonSize.sm,
                        fullWidth: true,
                        loading: busy,
                        onPressed: busy ? null : onLike,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppShape.space2),
              AppButton(
                label: 'View',
                icon: LucideIcons.eye,
                size: AppButtonSize.sm,
                fullWidth: true,
                loading: busy,
                onPressed: busy ? null : onView,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String? _summary(FeedProfile profile) => switch (profile) {
        FeedCompany(:final description) => description,
        FeedEmployee(:final description) => description,
      };

  static List<Widget> _chips(FeedProfile profile) {
    final (tags, benefits) = switch (profile) {
      FeedCompany() => (
          profile.openPositions.map((p) => p.title).toList(),
          profile.benefits,
        ),
      FeedEmployee() => (profile.skills, const <String>[]),
    };
    if (tags.isEmpty && benefits.isEmpty) return const [];

    const shown = 3;
    return [
      const SizedBox(height: AppShape.space3),
      Wrap(
        spacing: AppShape.space2,
        runSpacing: AppShape.space2,
        children: [
          for (final tag in tags.take(shown)) AppTag(label: tag),
          if (tags.length > shown) AppTag(label: '+${tags.length - shown}'),
          for (final benefit in benefits.take(2))
            AppCategoryChip(category: AppCategory.pink, label: benefit),
        ],
      ),
    ];
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.profile});

  final FeedProfile profile;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final profile = this.profile;

    final (headline, meta) = switch (profile) {
      FeedCompany() => (
          profile.industry,
          <(IconData, String)>[
            if (profile.location != null)
              (LucideIcons.mapPin, profile.location!),
            if (profile.companySize != null)
              (LucideIcons.users, '${profile.companySize} people'),
          ],
        ),
      FeedEmployee() => (
          profile.job,
          <(IconData, String)>[
            if (profile.location != null)
              (LucideIcons.mapPin, profile.location!),
            if (profile.yearsOfExperience != null)
              (LucideIcons.briefcase, profile.yearsOfExperience!),
            if (profile.availability != null)
              (LucideIcons.clock, humanize(profile.availability!)),
          ],
        ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          imageUrl: profile.avatarUrl,
          name: profile.displayName,
          size: AppAvatarSize.lg,
          squared: profile is FeedCompany,
        ),
        const SizedBox(width: AppShape.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label.copyWith(
                  color: t.foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: AppTypography.base,
                ),
              ),
              if (headline != null) ...[
                const SizedBox(height: 2),
                Text(
                  headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.tiny.copyWith(color: t.mutedForeground),
                ),
              ],
              if (meta.isNotEmpty) ...[
                const SizedBox(height: AppShape.space2),
                Wrap(
                  spacing: AppShape.space3,
                  runSpacing: AppShape.space1,
                  children: [
                    for (final (icon, label) in meta)
                      MetaChip(icon: icon, label: label),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The card's loading shape. Same padding and rhythm, so nothing jumps when
/// the real cards arrive.
class FeedProfileCardSkeleton extends StatelessWidget {
  const FeedProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSkeleton(width: 56, height: 56),
              SizedBox(width: AppShape.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: 160, height: 16),
                    SizedBox(height: AppShape.space2),
                    AppSkeleton(width: 110, height: 12),
                    SizedBox(height: AppShape.space2),
                    AppSkeleton(width: 140, height: 12),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppShape.space3),
          AppSkeleton(height: 12),
          SizedBox(height: AppShape.space2),
          AppSkeleton(width: 220, height: 12),
          SizedBox(height: AppShape.space4),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: AppSkeleton(height: 44)),
                  SizedBox(width: AppShape.space2),
                  Expanded(child: AppSkeleton(height: 44)),
                ],
              ),
              SizedBox(height: AppShape.space2),
              AppSkeleton(height: 44),
            ],
          ),
        ],
      ),
    );
  }
}
