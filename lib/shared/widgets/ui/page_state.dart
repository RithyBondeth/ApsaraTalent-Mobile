import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_button.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/app_surface.dart';

enum PageStateVariant { empty, error }

/// An empty or error state, filling a page or nested inside a card.
///
/// The colour **is** the state here — blue for empty, red for error — which is
/// one of the few places the accent edge earns its 5px.
///
/// [icon] is not decoration. Without it every empty state in the app shows the
/// same inbox, so "no messages", "no interviews" and "no search results" become
/// indistinguishable at a glance — which is the state the web app was in while
/// they all shared one illustration. Pass a glyph that names *this* absence.
/// Error states always take the warning triangle, so [icon] is ignored there.
class PageState extends StatelessWidget {
  const PageState({
    super.key,
    required this.variant,
    required this.title,
    this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final PageStateVariant variant;
  final String title;
  final String? description;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Sits inside a section rather than being the page. Takes its type scale
  /// from that: subordinate to the card's own title, not competing with it.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isError = variant == PageStateVariant.error;
    final glyph =
        isError ? LucideIcons.triangleAlert : (icon ?? LucideIcons.inbox);

    final accentColor = isError ? t.destructive : t.primary;
    final frameSize = compact ? 44.0 : 80.0;
    final glyphSize = compact ? 20.0 : 36.0;

    return AppSurface(
      accent: isError ? SurfaceAccent.destructive : SurfaceAccent.primary,
      accentEdge: SurfaceAccentEdge.top,
      elevation: SurfaceElevation.md,
      color: isError ? t.destructive.withValues(alpha: 0.025) : null,
      padding: EdgeInsets.symmetric(
        horizontal: AppShape.space4,
        vertical: compact ? 36 : AppShape.space12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // State Visual Section
          Container(
            height: frameSize,
            width: frameSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.25),
                width: AppShape.hairline,
              ),
            ),
            child: Icon(
              glyph,
              size: glyphSize,
              color: isError ? t.destructive : t.accentForeground,
            ),
          ),

          // State Copy Section
          //
          // Scale follows where this lives: subordinate inside a section,
          // prominent when it *is* the page. Using the page-title weight in
          // both is how a settings-card empty state ended up typeset larger
          // than the card's own heading.
          SizedBox(height: compact ? AppShape.space3 : AppShape.space4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: (compact
                    ? AppTypography.h4.copyWith(fontSize: AppTypography.base)
                    : AppTypography.h4.copyWith(fontWeight: FontWeight.w900))
                .copyWith(color: isError ? t.destructive : t.foreground),
          ),
          if (description != null) ...[
            SizedBox(height: compact ? AppShape.space1 : AppShape.space2),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: (compact ? AppTypography.tiny : AppTypography.small)
                  .copyWith(color: t.mutedForeground, height: 1.55),
            ),
          ],

          // State Action Section
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: compact ? AppShape.space3 : AppShape.space4),
            AppButton(
              label: actionLabel!,
              onPressed: onAction,
              size: AppButtonSize.sm,
              variant: isError
                  ? AppButtonVariant.outline
                  : AppButtonVariant.primary,
            ),
          ],
        ],
      ),
    );
  }
}
