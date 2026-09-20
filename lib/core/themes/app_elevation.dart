import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_tokens.dart';

/// Elevation is a **hard offset shadow with no blur** — the square UI casts a
/// solid block, not a soft glow — and it is a four-step ladder. Never write an
/// arbitrary shadow; a one-off is how the web app's 34 hand-written values
/// drifted across 3–9px offsets and 0.035–0.18 alphas before they were
/// collapsed into this ladder.
///
///  * [xs] — inline controls, chips, small toggles
///  * [sm] — a surface nested inside an already-raised one
///  * [md] — the default: cards, panels, list items, the page banner
///  * [lg] — floats over the page: dialogs, sheets, popovers
///  * [primaryXs] / [primary] — a filled-primary surface (the active nav item,
///    a selected setting card) casting its own hue instead of grime
///
/// The dark alphas are roughly tripled. The shadow is near-white on a near-black
/// page there, so the light-mode alphas render as an invisible haze; the higher
/// values keep the block reading as a cast shadow while staying under the
/// lightness step between `background` and `card` that does most of the
/// separating in dark mode.
@immutable
class AppElevation extends ThemeExtension<AppElevation> {
  const AppElevation({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.primaryXs,
    required this.primary,
  });

  final List<BoxShadow> xs;
  final List<BoxShadow> sm;
  final List<BoxShadow> md;
  final List<BoxShadow> lg;
  final List<BoxShadow> primaryXs;
  final List<BoxShadow> primary;

  /// `blurRadius: 0` is the whole point — this is an offset block, not a bloom.
  static List<BoxShadow> _hard(double offset, Color color, double alpha) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          offset: Offset(offset, offset),
          blurRadius: 0,
        ),
      ];

  static AppElevation of(AppTokens tokens, {required bool isDark}) {
    final ink = tokens.foreground;
    final brand = tokens.primary;
    return AppElevation(
      xs: _hard(2, ink, isDark ? 0.16 : 0.06),
      sm: _hard(3, ink, isDark ? 0.14 : 0.05),
      md: _hard(5, ink, isDark ? 0.15 : 0.055),
      lg: _hard(8, ink, isDark ? 0.2 : 0.08),
      primaryXs: _hard(2, brand, isDark ? 0.3 : 0.22),
      primary: _hard(3, brand, isDark ? 0.3 : 0.22),
    );
  }

  @override
  AppElevation copyWith() => this;

  @override
  AppElevation lerp(ThemeExtension<AppElevation>? other, double t) {
    if (other is! AppElevation) return this;
    return t < 0.5 ? this : other;
  }
}
