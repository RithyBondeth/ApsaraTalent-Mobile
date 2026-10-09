import 'package:apsaratalent_mobile/core/constants/asset_path_constant.dart';
import 'package:apsaratalent_mobile/core/constants/brand_dimensions.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Approved AT artwork, shared byte for byte with the web app.
/// Each theme uses its primary blue; the dark wordmark is white.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 32, this.withoutTitle = false});

  /// Rendered height in logical pixels. Width follows the artwork's own ratio.
  final double height;

  /// The AT monogram without the wordmark.
  final bool withoutTitle;

  @override
  Widget build(BuildContext context) {
    final asset = withoutTitle
        ? (context.isDark
            ? AppAssetPathContant.logoWithoutTitleDark
            : AppAssetPathContant.logoWithoutTitle)
        : (context.isDark
            ? AppAssetPathContant.logoForBlackBg
            : AppAssetPathContant.logoForWhiteBg);
    final width = height *
        (withoutTitle ? brandSymbolAspectRatio : brandLockupAspectRatio);

    return Image.asset(
      asset,
      height: height,
      width: width,
      fit: BoxFit.contain,
      // Decode at display size rather than retaining the export's full bitmap.
      cacheHeight: (height * MediaQuery.devicePixelRatioOf(context)).round(),
      semanticLabel: 'Apsara Talent',
    );
  }
}
