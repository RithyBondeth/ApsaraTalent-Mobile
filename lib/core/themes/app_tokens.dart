import 'package:flutter/material.dart';

/// Colour tokens, ported one-for-one from the web app's `app/globals.css`.
///
/// The values are kept in HSL exactly as they are written there so the two
/// files can be diffed line by line when the palette moves. Converting them to
/// hex here would make every future sync a manual re-derivation.
///
/// The palette is a port of Notion's: neutral-first and near-monochrome — a
/// pure white page, warm-grey ink, quiet surfaces, and colour only where
/// something is interactive or a label differs in kind.
///
/// Three groups, and the rules that come with them:
///
///  * **Neutral** — [background], [card], [popover], [muted], [border],
///    [input], [primary], [secondary], [accent]. [border] is decorative;
///    [input] bounds interactive controls and is deliberately darker to hold
///    3:1 (WCAG 1.4.11). Don't collapse them into one value.
///  * **Status** — [success], [warning], [info], [destructive], for severity.
///    Five roles each: the bare token is the solid fill, plus `Foreground`
///    (on that fill), `Accent` (text on page/card/subtle), `Subtle` (tinted
///    surface) and `Border`.
///  * **Categorical** — [categoryBrown] … [categoryBlue] with `Accent` and
///    `Subtle`, for labels that differ in *kind*: notification type, company
///    benefits, employee availability. Never borrow a status colour for these —
///    spending amber on "freelance" is what stops a real warning from standing
///    out. There is no categorical green or red on purpose: those are spoken
///    for by [success] and [destructive], and a category must never be
///    mistakable for a state.
///
/// Every token resolves per theme on its own — read them through
/// `context.tokens` and never branch on brightness at the call site. A
/// `context.isDark ? a : b` in a widget is the same mistake as a `dark:` variant
/// on a token class in the web app: it reintroduces a second palette.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.success,
    required this.successForeground,
    required this.successAccent,
    required this.successSubtle,
    required this.successBorder,
    required this.warning,
    required this.warningForeground,
    required this.warningAccent,
    required this.warningSubtle,
    required this.warningBorder,
    required this.info,
    required this.infoForeground,
    required this.infoAccent,
    required this.infoSubtle,
    required this.infoBorder,
    required this.destructive,
    required this.destructiveForeground,
    required this.destructiveAccent,
    required this.destructiveSubtle,
    required this.destructiveBorder,
    required this.categoryPurple,
    required this.categoryPurpleAccent,
    required this.categoryPurpleSubtle,
    required this.categoryPink,
    required this.categoryPinkAccent,
    required this.categoryPinkSubtle,
    required this.categoryBrown,
    required this.categoryBrownAccent,
    required this.categoryBrownSubtle,
    required this.categoryBlue,
    required this.categoryBlueAccent,
    required this.categoryBlueSubtle,
    required this.categoryOrange,
    required this.categoryOrangeAccent,
    required this.categoryOrangeSubtle,
    required this.categoryGray,
    required this.categoryGrayAccent,
    required this.categoryGraySubtle,
    required this.border,
    required this.input,
    required this.ring,
    required this.scrim,
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
  });

  /* ------------------------------- Neutral -------------------------------- */
  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color popover;
  final Color popoverForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;

  /* -------------------------------- Status -------------------------------- */
  final Color success;
  final Color successForeground;
  final Color successAccent;
  final Color successSubtle;
  final Color successBorder;

  final Color warning;
  final Color warningForeground;
  final Color warningAccent;
  final Color warningSubtle;
  final Color warningBorder;

  final Color info;
  final Color infoForeground;
  final Color infoAccent;
  final Color infoSubtle;
  final Color infoBorder;

  final Color destructive;
  final Color destructiveForeground;
  final Color destructiveAccent;
  final Color destructiveSubtle;
  final Color destructiveBorder;

  /* ----------------------------- Categorical ------------------------------ */
  final Color categoryPurple;
  final Color categoryPurpleAccent;
  final Color categoryPurpleSubtle;

  final Color categoryPink;
  final Color categoryPinkAccent;
  final Color categoryPinkSubtle;

  final Color categoryBrown;
  final Color categoryBrownAccent;
  final Color categoryBrownSubtle;

  final Color categoryBlue;
  final Color categoryBlueAccent;
  final Color categoryBlueSubtle;

  final Color categoryOrange;
  final Color categoryOrangeAccent;
  final Color categoryOrangeSubtle;

  final Color categoryGray;
  final Color categoryGrayAccent;
  final Color categoryGraySubtle;

  /* ------------------------------ Structural ------------------------------ */

  /// Decorative: dividers and card edges. Stays quiet.
  final Color border;

  /// Bounds interactive controls, so it carries the 3:1 that WCAG 1.4.11 asks
  /// of a component boundary. Deliberately darker than [border].
  final Color input;
  final Color ring;

  /// The veil behind a modal. Deliberately **not** derived from [foreground]:
  /// that token inverts per theme, so a foreground-based scrim would put a
  /// white wash over the page in dark mode. A scrim darkens in both themes.
  final Color scrim;

  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;

  /// Mirrors CSS `hsl(H S% L%)`, so a token below can be read straight across
  /// from `globals.css` without arithmetic.
  static Color _hsl(double h, double s, double l) =>
      HSLColor.fromAHSL(1, h, s / 100, l / 100).toColor();

  /* ------------------------------------------------------------------------ */
  /* Light                                                                    */
  /*                                                                          */
  /* The page, cards and popovers are all 0 0% 100%, so a card is delineated  */
  /* by its border hairline and its hard offset shadow rather than by a       */
  /* lightness step.                                                          */
  /* ------------------------------------------------------------------------ */
  static final AppTokens light = AppTokens(
    background: _hsl(0, 0, 100),
    foreground: _hsl(45, 7.8, 20),
    card: _hsl(0, 0, 100),
    cardForeground: _hsl(45, 7.8, 20),
    popover: _hsl(0, 0, 100),
    popoverForeground: _hsl(45, 7.8, 20),
    // Notion's action blue, nudged down in lightness (hue and saturation
    // untouched) so a white label on it clears AA. Their literal #2383E2 is
    // 3.88:1 on white; don't "correct" it back.
    primary: _hsl(209.8, 76.7, 44.5),
    primaryForeground: _hsl(0, 0, 100),
    secondary: _hsl(60, 6.7, 94.1),
    secondaryForeground: _hsl(45, 7.8, 20),
    muted: _hsl(45, 20, 96.1),
    mutedForeground: _hsl(45, 1.7, 41.7),
    accent: _hsl(197.6, 54.8, 93.9),
    accentForeground: _hsl(201.9, 53.6, 39.5),
    success: _hsl(147.6, 31.7, 39),
    successForeground: _hsl(0, 0, 100),
    successAccent: _hsl(147.6, 31.7, 36.1),
    successSubtle: _hsl(111.4, 22.6, 93.9),
    successBorder: _hsl(111.4, 22.6, 79.9),
    warning: _hsl(37.7, 62.4, 49),
    warningForeground: _hsl(37.7, 55, 14),
    warningAccent: _hsl(37.7, 62.4, 35.1),
    warningSubtle: _hsl(45, 80, 92.2),
    warningBorder: _hsl(45, 80, 72.4),
    info: _hsl(201.9, 53.6, 42.9),
    infoForeground: _hsl(0, 0, 100),
    infoAccent: _hsl(201.9, 53.6, 39.5),
    infoSubtle: _hsl(197.6, 54.8, 93.9),
    infoBorder: _hsl(197.6, 54.8, 79.9),
    // Doubles as the danger status. Its lightness is picked so the one token
    // works both as a fill (with destructiveForeground on top) and as text
    // straight on the page.
    destructive: _hsl(2.1, 62.1, 53.8),
    destructiveForeground: _hsl(0, 0, 100),
    destructiveAccent: _hsl(2.1, 62.1, 48.7),
    destructiveSubtle: _hsl(356.7, 81.8, 95.7),
    destructiveBorder: _hsl(356.7, 81.8, 81.7),
    categoryPurple: _hsl(274.4, 32.2, 54.3),
    categoryPurpleAccent: _hsl(274.4, 32.2, 52),
    categoryPurpleSubtle: _hsl(270, 33.3, 96.5),
    categoryPink: _hsl(328.2, 48.5, 52.7),
    categoryPinkAccent: _hsl(328.2, 48.5, 49.5),
    categoryPinkSubtle: _hsl(333.3, 47.4, 96.3),
    categoryBrown: _hsl(18.9, 31.4, 47.5),
    categoryBrownAccent: _hsl(18.9, 31.4, 43.4),
    categoryBrownSubtle: _hsl(0, 21.4, 94.5),
    categoryBlue: _hsl(201.9, 53.6, 43.1),
    categoryBlueAccent: _hsl(201.9, 53.6, 39.5),
    categoryBlueSubtle: _hsl(197.6, 54.8, 93.9),
    categoryOrange: _hsl(30, 88.7, 45.1),
    categoryOrangeAccent: _hsl(30, 88.7, 34.3),
    categoryOrangeSubtle: _hsl(29, 74.4, 92.4),
    categoryGray: _hsl(45, 1.7, 46.3),
    categoryGrayAccent: _hsl(45, 1.7, 42.9),
    categoryGraySubtle: _hsl(60, 6.7, 94.1),
    border: _hsl(60, 4.3, 87.9),
    input: _hsl(60, 4.3, 56.7),
    ring: _hsl(209.8, 76.7, 44.5),
    scrim: _hsl(0, 0, 5.9),
    chart1: _hsl(209.8, 76.7, 44.5),
    chart2: _hsl(147.6, 31.7, 36.1),
    chart3: _hsl(30, 88.7, 34.3),
    chart4: _hsl(274.4, 32.2, 52),
    chart5: _hsl(328.2, 48.5, 49.5),
  );

  /* ------------------------------------------------------------------------ */
  /* Dark                                                                     */
  /*                                                                          */
  /* Surfaces step up in lightness: page 9.8% -> card 12.5% -> popover 18.4%  */
  /* -> muted 21.6%. Dark mode has no usable drop shadow to lean on (the hard */
  /* offset shadow is near-white at low alpha), so the step itself is what    */
  /* separates one surface from the next.                                    */
  /* ------------------------------------------------------------------------ */
  static final AppTokens dark = AppTokens(
    background: _hsl(0, 0, 9.8),
    foreground: _hsl(0, 0, 83.1),
    card: _hsl(0, 0, 12.5),
    cardForeground: _hsl(0, 0, 83.1),
    popover: _hsl(0, 0, 18.4),
    popoverForeground: _hsl(0, 0, 83.1),
    // Dark mode takes the logo's highlight tone rather than its outline tone;
    // the deep one disappears on a black page.
    primary: _hsl(203, 53.1, 55.7),
    primaryForeground: _hsl(209.8, 60, 12),
    secondary: _hsl(0, 0, 18.4),
    secondaryForeground: _hsl(0, 0, 83.1),
    muted: _hsl(0, 0, 21.6),
    mutedForeground: _hsl(0, 0, 71.2),
    accent: _hsl(200.7, 59.2, 19.2),
    accentForeground: _hsl(203, 53.1, 60),
    success: _hsl(145.3, 31.7, 47.1),
    successForeground: _hsl(145.3, 31.7, 12),
    successAccent: _hsl(145.3, 31.7, 54.3),
    successSubtle: _hsl(148.8, 25.8, 19),
    successBorder: _hsl(148.8, 25.8, 31),
    warning: _hsl(36.7, 54.9, 53.9),
    warningForeground: _hsl(36.7, 54.9, 12),
    warningAccent: _hsl(36.7, 54.9, 64.5),
    warningSubtle: _hsl(33.8, 29.3, 26.1),
    warningBorder: _hsl(33.8, 29.3, 38.1),
    info: _hsl(217, 49.8, 57.8),
    infoForeground: _hsl(217, 49.8, 12),
    infoAccent: _hsl(217, 49.8, 66.5),
    infoSubtle: _hsl(200.7, 59.2, 19.2),
    infoBorder: _hsl(200.7, 59.2, 31.2),
    destructive: _hsl(0.9, 68.8, 61.4),
    destructiveForeground: _hsl(0.9, 55, 12),
    destructiveAccent: _hsl(0.9, 68.8, 71),
    destructiveSubtle: _hsl(6, 32.3, 24.3),
    destructiveBorder: _hsl(6, 32.3, 36.3),
    categoryPurple: _hsl(269.7, 54.9, 61.8),
    categoryPurpleAccent: _hsl(269.7, 54.9, 70),
    categoryPurpleSubtle: _hsl(272.1, 23.7, 23.1),
    categoryPink: _hsl(329, 57, 58),
    categoryPinkAccent: _hsl(329, 57, 68.7),
    categoryPinkSubtle: _hsl(331.8, 27.9, 23.9),
    categoryBrown: _hsl(17, 34.9, 58.4),
    categoryBrownAccent: _hsl(17, 34.9, 64.1),
    categoryBrownSubtle: _hsl(17.6, 29.8, 22.4),
    categoryBlue: _hsl(217, 49.8, 57.8),
    categoryBlueAccent: _hsl(217, 49.8, 66.5),
    categoryBlueSubtle: _hsl(200.7, 59.2, 19.2),
    categoryOrange: _hsl(25, 53.1, 53.1),
    categoryOrangeAccent: _hsl(25, 53.1, 67.1),
    categoryOrangeSubtle: _hsl(25.3, 44.9, 24.9),
    categoryGray: _hsl(0, 0, 60.8),
    categoryGrayAccent: _hsl(0, 0, 60.8),
    categoryGraySubtle: _hsl(0, 0, 18.4),
    border: _hsl(0, 0, 18.3),
    input: _hsl(0, 0, 41.4),
    ring: _hsl(203, 53.1, 55.7),
    scrim: _hsl(0, 0, 4),
    chart1: _hsl(203, 53.1, 55.7),
    chart2: _hsl(145.3, 31.7, 54.3),
    chart3: _hsl(25, 53.1, 67.1),
    chart4: _hsl(269.7, 54.9, 70),
    chart5: _hsl(329, 57, 68.7),
  );

  @override
  AppTokens copyWith() => this;

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    // Tokens are a fixed pair, not a continuum: the app swaps light for dark
    // wholesale. Interpolating them would produce a frame of colours that clear
    // no contrast threshold in either theme, so snap at the midpoint instead.
    if (other is! AppTokens) return this;
    return t < 0.5 ? this : other;
  }
}
