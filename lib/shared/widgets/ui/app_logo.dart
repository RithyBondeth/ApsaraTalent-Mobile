import 'package:apsaratalent_mobile/core/constants/asset_path_constant.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// The brand mark — the same three files the web app ships, byte for byte.
///
/// The lockup pairs the dancer with a near-black "APSARA" that all but vanishes
/// on the dark theme's page, so it has a twin lettered in white. That is the one
/// legitimate place to branch on [AppThemeContext.isDark]: the two lockups are
/// different files, not one colour resolved twice, so no token can express the
/// choice. The icon-only mark is blue and white throughout with no wordmark to
/// lose, so it reads on either theme and needs no twin.
///
/// Mirrors the web's `components/utils/brand/logo.tsx`, including its ratios.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 56, this.withoutTitle = false});

  /// Rendered height in logical pixels. Width follows the artwork's own ratio.
  /// The web's auth pages render the lockup at `h-16`, i.e. 64.
  final double height;

  /// Icon-only mark — the dancer without the wordmark.
  final bool withoutTitle;

  /// The files are trimmed to their alpha box, so these are simply their pixel
  /// dimensions. Both lockups share a rectangle on purpose, so one ratio serves
  /// the pair.
  static const double _lockupRatio = 1542 / 884;
  static const double _iconRatio = 843 / 1206;

  @override
  Widget build(BuildContext context) {
    final asset = withoutTitle
        ? AppAssetPathContant.logoWithoutTitle
        : (context.isDark
            ? AppAssetPathContant.logoForBlackBg
            : AppAssetPathContant.logoForWhiteBg);
    final width = height * (withoutTitle ? _iconRatio : _lockupRatio);

    return Image.asset(
      asset,
      height: height,
      width: width,
      fit: BoxFit.contain,
      // The sources are 1542px wide and render at ~110pt. Decoding at display
      // size instead of full resolution keeps a ~5 MB bitmap out of memory for
      // a mark this small — the job next/image's optimiser does on the web.
      cacheHeight: (height * MediaQuery.devicePixelRatioOf(context)).round(),
      semanticLabel: 'Apsara Talent',
    );
  }
}
