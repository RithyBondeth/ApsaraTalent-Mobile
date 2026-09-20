import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_surface.dart';

/// One stat in a banner: a count the page has already loaded.
class PageBannerStat {
  const PageBannerStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

/// The banner at the top of every signed-in page.
///
/// **There is no illustration here, and that is deliberate.** The web app's
/// banners used to be a two-column hero whose right half held a decorative SVG.
/// The artwork carried no information — it was `alt=""` with every sibling
/// hidden from the accessibility tree — while costing 146–320 KB a page,
/// preloading with `priority`, and eating ~68% of the fold on a 375px phone.
/// None of the files used `currentColor`, so they could not follow the theme
/// either. All eleven were deleted. Do not reintroduce one.
///
/// The space goes to [stats] instead: counts the page has already loaded. A
/// banner that reports the state of someone's pipeline earns its height in a
/// way a stock drawing does not.
///
/// Withhold [stats] until the data has actually arrived — pass `null`, not
/// zeroes, so a placeholder "0" doesn't flash and then reflow.
///
/// The left edge is the one accent-coloured edge on the page. That is the whole
/// reason it reads as page identity; a second one anywhere else on the screen
/// spends it.
class PageBanner extends StatelessWidget {
  const PageBanner({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.stats,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final List<PageBannerStat>? stats;

  /// Controls that belong to the page as a whole — a filter row, a primary
  /// action. Sits below the copy and the stats.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hasStats = stats != null && stats!.isNotEmpty;

    return AppSurface(
      accent: SurfaceAccent.primary,
      accentEdge: SurfaceAccentEdge.left,
      elevation: SurfaceElevation.md,
      padding: const EdgeInsets.symmetric(
        horizontal: AppShape.space5,
        vertical: AppShape.space5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow Section
          Row(
            children: [
              Container(height: 1, width: 28, color: t.primary),
              const SizedBox(width: AppShape.space2),
              Flexible(
                child: Text(
                  eyebrow.toUpperCase(),
                  style: AppTypography.eyebrow.copyWith(
                    color: t.mutedForeground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Title Section
          const SizedBox(height: AppShape.space3),
          Text(
            title,
            style: AppTypography.bannerTitle.copyWith(color: t.foreground),
          ),

          // Subtitle Section
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              subtitle!,
              style: AppTypography.small.copyWith(
                color: t.mutedForeground,
                height: 1.55,
              ),
            ),
          ],

          // Stats Section
          //
          // A phone is below the web's `tablet-md` breakpoint, where the stats
          // column drops under the copy and wraps. Three long labels like "new
          // this week" would otherwise collide at 375px.
          if (hasStats) ...[
            const SizedBox(height: AppShape.space5),
            Wrap(
              spacing: AppShape.space6,
              runSpacing: AppShape.space3,
              children: [
                for (final stat in stats!) _Stat(stat: stat),
              ],
            ),
          ],

          if (trailing != null) ...[
            const SizedBox(height: AppShape.space5),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.stat});

  final PageBannerStat stat;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(stat.icon, size: 13, color: t.mutedForeground),
            const SizedBox(width: 5),
            Text(
              stat.label.toUpperCase(),
              style: AppTypography.statLabel.copyWith(
                color: t.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppShape.space1),
        Text(
          stat.value,
          style: AppTypography.statValue.copyWith(color: t.foreground),
        ),
      ],
    );
  }
}

/// The banner's loading shape.
///
/// It carries the **same** outer geometry as the real banner — same padding,
/// same accent edge, same elevation — because a skeleton whose shape differs
/// from what replaces it is the reflow the skeleton exists to prevent. Pass
/// [stats] only for pages that hand the banner its counts on first paint;
/// drawing a stats row the banner won't have is the same bug in the other
/// direction.
class PageBannerSkeleton extends StatelessWidget {
  const PageBannerSkeleton({super.key, this.stats = 0});

  final int stats;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          color: t.muted,
        );

    return AppSurface(
      accent: SurfaceAccent.primary,
      accentEdge: SurfaceAccentEdge.left,
      elevation: SurfaceElevation.md,
      padding: const EdgeInsets.symmetric(
        horizontal: AppShape.space5,
        vertical: AppShape.space5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(120, 11),
          const SizedBox(height: AppShape.space3),
          bar(220, 26),
          const SizedBox(height: 10),
          bar(double.infinity, 14),
          if (stats > 0) ...[
            const SizedBox(height: AppShape.space5),
            Wrap(
              spacing: AppShape.space6,
              runSpacing: AppShape.space3,
              children: [
                for (var i = 0; i < stats; i++)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      bar(64, 10),
                      const SizedBox(height: AppShape.space1),
                      bar(40, 24),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
