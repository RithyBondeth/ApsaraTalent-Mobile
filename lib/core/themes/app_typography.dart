import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The type scale, ported from the web app's Tailwind classes.
///
/// Two things to know before adding to this:
///
/// **Sizes are the phone end of the web's responsive pairs.** Web headings are
/// written `text-2xl sm:text-3xl`, and Tailwind's `sm:` is a *min-width* 640px
/// breakpoint — a 402pt phone never reaches it. So the mobile value of
/// `text-2xl sm:text-3xl` is 24, not 30. Porting the desktop half of those
/// pairs is the single easiest way to end up with a heading that eats the fold.
///
/// **Tracking is in ems on the web and logical pixels here.** Tailwind's
/// `tracking-tight` is `-0.025em`, which scales with the font; Flutter's
/// `letterSpacing` does not. Each style below therefore carries its tracking
/// already multiplied out against its own size, which is why they are written
/// as literals rather than derived from a shared constant.
class AppTypography {
  const AppTypography._();

  /* --------------------------- Tailwind sizes ----------------------------- */
  static const double xs = 12; // text-xs
  static const double sm = 14; // text-sm
  static const double base = 16; // text-base
  static const double lg = 18; // text-lg
  static const double xl = 20; // text-xl
  static const double xl2 = 24; // text-2xl
  static const double xl3 = 30; // text-3xl
  static const double xl4 = 36; // text-4xl

  /// Ubuntu is the web app's `--font-ubuntu`. Khmer copy falls back to Koh
  /// Santepheap, matching `--font-khmer`.
  static TextStyle _font({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) =>
      GoogleFonts.ubuntu(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  /* ------------------------------ Headings -------------------------------- */

  /// `text-4xl font-extrabold tracking-tight` — the page `h1`. Reserved for a
  /// page's own title; a section heading is [h3] or smaller.
  static TextStyle get h1 =>
      _font(fontSize: xl4, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.9);

  /// `text-2xl font-semibold tracking-tight` (the web's `sm:text-3xl` half does
  /// not apply on a phone).
  static TextStyle get h2 =>
      _font(fontSize: xl2, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.6);

  /// `text-2xl font-semibold tracking-tight`
  static TextStyle get h3 =>
      _font(fontSize: xl2, fontWeight: FontWeight.w600, height: 1.25, letterSpacing: -0.6);

  /// `text-xl font-semibold tracking-tight`
  static TextStyle get h4 =>
      _font(fontSize: xl, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: -0.5);

  /* -------------------------------- Body ---------------------------------- */

  /// `leading-7` — body copy.
  static TextStyle get p =>
      _font(fontSize: base, fontWeight: FontWeight.w400, height: 1.75);

  /// `text-xl text-muted-foreground` — the standfirst under a heading. Colour
  /// is applied at the call site from `context.tokens.mutedForeground`.
  static TextStyle get lead =>
      _font(fontSize: xl, fontWeight: FontWeight.w400, height: 1.5);

  /// `text-sm`
  static TextStyle get small =>
      _font(fontSize: sm, fontWeight: FontWeight.w400, height: 1.5);

  /// `text-sm text-muted-foreground`
  static TextStyle get muted =>
      _font(fontSize: sm, fontWeight: FontWeight.w400, height: 1.45);

  /// `text-xs`
  static TextStyle get tiny =>
      _font(fontSize: xs, fontWeight: FontWeight.w400, height: 1.4);

  /* ------------------------------- Controls ------------------------------- */

  /// `text-sm font-medium` — the button label.
  static TextStyle get button =>
      _font(fontSize: sm, fontWeight: FontWeight.w500, height: 1.2);

  /// `text-base` in the field, `text-sm` for its placeholder.
  static TextStyle get field =>
      _font(fontSize: base, fontWeight: FontWeight.w400, height: 1.3);

  static TextStyle get label =>
      _font(fontSize: sm, fontWeight: FontWeight.w500, height: 1.3);

  /* ------------------------------- Banner --------------------------------- */

  /// `text-[11px] font-bold uppercase tracking-[0.2em]` — the banner eyebrow
  /// and every other all-caps kicker.
  static TextStyle get eyebrow =>
      _font(fontSize: 11, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: 2.2);

  /// `text-2xl font-bold leading-[1.08] tracking-[-0.04em]`
  static TextStyle get bannerTitle =>
      _font(fontSize: xl2, fontWeight: FontWeight.w700, height: 1.08, letterSpacing: -0.96);

  /// `text-[10px] font-bold uppercase tracking-[0.14em]` — a stat's label.
  static TextStyle get statLabel =>
      _font(fontSize: 10, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: 1.4);

  /// `text-2xl font-black tabular-nums tracking-[-0.04em]` — a stat's value.
  /// [FontFeature.tabularFigures] is what keeps a counting number from
  /// reflowing its neighbours as it ticks.
  static TextStyle get statValue => _font(
        fontSize: xl2,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: -0.96,
      ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /* -------------------------------- Chips --------------------------------- */

  /// `text-xs font-semibold uppercase tracking-wide` — the status pill.
  static TextStyle get pill =>
      _font(fontSize: xs, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.6);

  /// `text-xs font-medium leading-none` — the neutral tag.
  static TextStyle get tag =>
      _font(fontSize: xs, fontWeight: FontWeight.w500, height: 1.1);
}
