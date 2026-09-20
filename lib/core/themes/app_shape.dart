/// Shape and spacing constants.
///
/// **The UI is square.** [radius] is 0 and that is the app's own decision, not
/// an oversight inherited from a starter theme — the web app runs 1100+
/// square corners against a handful of rounded ones, and its `--radius` token
/// is `0rem` so the primitives agree. Corners are only ever round on things
/// that are *circles*: avatars, dots and pills, which use [pill].
///
/// Reaching for a 4px or 8px corner "just here" is what puts the two platforms
/// visibly out of step, since a phone screen shows few enough surfaces that one
/// rounded card among square ones reads as a bug.
class AppShape {
  const AppShape._();

  /// Square. See the class doc before changing this.
  static const double radius = 0;

  /// Avatars, dots, status dots and pills — the only round things.
  static const double pill = 9999;

  /* ------------------------------- Borders -------------------------------- */

  /// The default hairline. Every surface gets one of these.
  static const double hairline = 1;

  /// An *inline* accent: a passage of content inside a surface — callouts,
  /// quote blocks, chat rows. **Semantic only.** A card does not get one for
  /// being a card.
  static const double accentInline = 4;

  /// A *surface* accent: the one edge on a page that carries information.
  /// **Semantic only**, and rationed — the web app allows it on the page
  /// banner (page identity), the page state (empty vs error), the active chat
  /// row and focused input (selection), AI-suggestion callouts, and interview
  /// and resume-upload states. Nothing else.
  ///
  /// If you are adding one, the question is not "does this look important" — it
  /// is "does the colour of this edge tell the reader something the rest of the
  /// card does not". If it doesn't, it's a [hairline].
  static const double accentSurface = 5;

  /* ------------------------------- Spacing -------------------------------- */
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;

  /// The gutter every screen's content sits inside.
  static const double screenPadding = 16;

  /* -------------------------------- Controls ------------------------------ */

  /// Buttons: `h-11` on the web default, `h-10` small, `h-12` large. Phone
  /// targets keep the 44pt minimum, so the small step floors there.
  static const double controlHeightSm = 44;
  static const double controlHeightMd = 48;
  static const double controlHeightLg = 52;

  /// Inputs are `h-12` on the web and stay taller than the default button.
  static const double fieldHeight = 52;
}
