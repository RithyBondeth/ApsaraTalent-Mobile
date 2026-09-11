import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_tokens.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';

/// Severity, not kind. Four families and no more.
enum AppStatus { success, warning, info, destructive }

enum AppStatusPillVariant {
  /// Tinted surface with accent text — the default, and quiet enough to sit in
  /// a list without shouting.
  subtle,

  /// Solid fill. For the one status on screen that must be seen first.
  solid,
}

/// One pill for every "this thing has a state" badge in the app.
///
/// Before the web app had this, each caller hand-rolled its own colour
/// combination, which is how the same "success" ended up green in one file and
/// emerald in the next. Route every status badge through here.
///
/// Do not reach for this to label a *kind* of thing — an employment type, a
/// notification category, a benefit. Those are [AppCategoryChip]. Spending
/// amber on "freelance" is exactly what stops a real warning from standing out.
class AppStatusPill extends StatelessWidget {
  const AppStatusPill({
    super.key,
    required this.status,
    required this.label,
    this.variant = AppStatusPillVariant.subtle,
    this.dot = false,
  });

  final AppStatus status;
  final String label;
  final AppStatusPillVariant variant;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final solid = variant == AppStatusPillVariant.solid;
    final scheme = _schemeFor(t, status);

    final background = solid ? scheme.solid : scheme.subtle;
    final foreground = solid ? scheme.onSolid : scheme.accent;
    final edge = solid ? scheme.solid : scheme.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: edge, width: AppShape.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              height: 6,
              width: 6,
              decoration: BoxDecoration(
                // On a solid fill the dot takes the foreground colour; the
                // status hue would vanish into its own background.
                color: solid ? scheme.onSolid : scheme.solid,
                borderRadius: BorderRadius.circular(AppShape.pill),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.pill.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }

  _StatusScheme _schemeFor(AppTokens t, AppStatus status) => switch (status) {
        AppStatus.success => _StatusScheme(
            solid: t.success,
            onSolid: t.successForeground,
            accent: t.successAccent,
            subtle: t.successSubtle,
            border: t.successBorder,
          ),
        AppStatus.warning => _StatusScheme(
            solid: t.warning,
            onSolid: t.warningForeground,
            accent: t.warningAccent,
            subtle: t.warningSubtle,
            border: t.warningBorder,
          ),
        AppStatus.info => _StatusScheme(
            solid: t.info,
            onSolid: t.infoForeground,
            accent: t.infoAccent,
            subtle: t.infoSubtle,
            border: t.infoBorder,
          ),
        AppStatus.destructive => _StatusScheme(
            solid: t.destructive,
            onSolid: t.destructiveForeground,
            accent: t.destructiveAccent,
            subtle: t.destructiveSubtle,
            border: t.destructiveBorder,
          ),
      };
}

class _StatusScheme {
  const _StatusScheme({
    required this.solid,
    required this.onSolid,
    required this.accent,
    required this.subtle,
    required this.border,
  });

  final Color solid;
  final Color onSolid;
  final Color accent;
  final Color subtle;
  final Color border;
}

/// Labels that differ in **kind**, not in severity.
///
/// Six hues, and they are Notion's six: brown, orange, purple, pink, gray and
/// blue. The set has no green and no red on purpose — those are spoken for by
/// [AppStatus.success] and [AppStatus.destructive], and a category must never
/// be mistakable for a state.
enum AppCategory { brown, orange, purple, pink, gray, blue }

/// The one categorical chip, the way [AppStatusPill] is the one status pill.
class AppCategoryChip extends StatelessWidget {
  const AppCategoryChip({
    super.key,
    required this.category,
    required this.label,
    this.icon,
  });

  final AppCategory category;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (accent, subtle) = switch (category) {
      AppCategory.brown => (t.categoryBrownAccent, t.categoryBrownSubtle),
      AppCategory.orange => (t.categoryOrangeAccent, t.categoryOrangeSubtle),
      AppCategory.purple => (t.categoryPurpleAccent, t.categoryPurpleSubtle),
      AppCategory.pink => (t.categoryPinkAccent, t.categoryPinkSubtle),
      AppCategory.gray => (t.categoryGrayAccent, t.categoryGraySubtle),
      AppCategory.blue => (t.categoryBlueAccent, t.categoryBlueSubtle),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: subtle,
        border: Border.all(
          color: accent.withValues(alpha: 0.28),
          width: AppShape.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: accent),
            const SizedBox(width: 5),
          ],
          Text(label, style: AppTypography.tag.copyWith(color: accent)),
        ],
      ),
    );
  }
}
