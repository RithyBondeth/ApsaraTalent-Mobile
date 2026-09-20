import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/features/feed/domain/entities/feed_profile.dart';
import 'package:apsaratalent_mobile/features/match/domain/entities/match_profile.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// One mutual match.
///
/// The matching list returns a trimmed record — no benefits, values or career
/// scopes, unlike the feed list — so this shows identity, fit and the two
/// actions rather than reusing the feed's card and rendering empty tag rows.
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    required this.busy,
    required this.onTap,
    required this.onMessage,
    required this.onUnmatch,
  });

  final MatchProfile match;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onMessage;
  final VoidCallback onUnmatch;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final profile = match.profile;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppShape.space3),
      child: AppSurface(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(
                  name: profile.displayName,
                  imageUrl: profile.avatarUrl,
                  size: AppAvatarSize.lg,
                ),
                const SizedBox(width: AppShape.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: AppTypography.label.copyWith(
                          color: t.foreground,
                          fontSize: AppTypography.base,
                        ),
                      ),
                      if (_subtitle(profile) case final subtitle?) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTypography.tiny.copyWith(
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
            const SizedBox(height: AppShape.space3),
            _Fit(match: match),
            const SizedBox(height: AppShape.space3),
            Divider(color: t.border, height: AppShape.hairline),
            const SizedBox(height: AppShape.space3),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Message',
                    icon: LucideIcons.messageCircle,
                    size: AppButtonSize.sm,
                    fullWidth: true,
                    onPressed: busy ? null : onMessage,
                  ),
                ),
                const SizedBox(width: AppShape.space2),
                Expanded(
                  child: AppButton(
                    label: 'Unmatch',
                    icon: LucideIcons.userMinus,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.sm,
                    fullWidth: true,
                    loading: busy,
                    onPressed: busy ? null : onUnmatch,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A company's industry, or a candidate's job title.
  static String? _subtitle(FeedProfile profile) => switch (profile) {
        FeedCompany(:final industry) => industry,
        FeedEmployee(:final job) => job,
      };
}

/// The two scores the matching list carries.
///
/// The bar is `primary` on `muted`, like profile completion: a fit is a
/// quantity, not a severity, and a low score is not a warning.
class _Fit extends StatelessWidget {
  const _Fit({required this.match});

  final MatchProfile match;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final score = match.matchScore.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Match score',
                style: AppTypography.tiny.copyWith(color: t.mutedForeground),
              ),
            ),
            Text(
              '$score%',
              style: AppTypography.label.copyWith(color: t.foreground),
            ),
          ],
        ),
        const SizedBox(height: AppShape.space2),
        Stack(
          children: [
            Container(height: 6, color: t.muted),
            FractionallySizedBox(
              widthFactor: score / 100,
              child: Container(height: 6, color: t.primary),
            ),
          ],
        ),
        if (match.skillScore > 0) ...[
          const SizedBox(height: AppShape.space2),
          Text(
            '${match.skillScore}% of it from overlapping skills',
            style: AppTypography.tiny.copyWith(color: t.mutedForeground),
          ),
        ],
      ],
    );
  }
}
