import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_elevation.dart';
import 'package:apsaratalent_mobile/core/themes/app_tokens.dart';

/// Reading the design system off a [BuildContext].
///
/// `context.tokens.primary` is the mobile equivalent of the web app's
/// `bg-primary`: the token resolves per theme on its own, so a call site never
/// branches on brightness. A `context.isDark ? a : b` in a widget is the same
/// mistake as writing `dark:bg-…` on a token class over there — it declares a
/// second palette that nothing gates and that drifts from the first.
///
/// The one legitimate use of [isDark] is picking between two *assets* (the
/// light-on-dark and dark-on-light logo files), which are genuinely two
/// different images rather than one colour resolved twice.
extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  /// Every colour in the app. See [AppTokens] for the three groups and the
  /// rules about which one a given label belongs to.
  AppTokens get tokens => theme.extension<AppTokens>()!;

  /// The hard offset shadow ladder. Four steps and nothing between them.
  AppElevation get elevation => theme.extension<AppElevation>()!;

  TextTheme get text => theme.textTheme;

  /// True in dark mode. Use for choosing between assets, not colours.
  bool get isDark => theme.brightness == Brightness.dark;

  MediaQueryData get media => MediaQuery.of(this);
  Size get screenSize => media.size;

  /// The web app's `tablet-md` breakpoint, the one that collapses the banner's
  /// stats column. Phones sit below it; this exists for tablets in landscape.
  bool get isCompactWidth => media.size.width < 600;
}
