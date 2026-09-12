import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_elevation.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';

/// Which edge, if any, carries an accent — and in which colour.
enum SurfaceAccent { none, primary, destructive, success, warning, info }

enum SurfaceAccentEdge { top, left, right, bottom }

/// Which step of the elevation ladder a surface sits on.
enum SurfaceElevation { none, xs, sm, md, lg }

/// The app's card: a square panel with a hairline edge and a hard offset
/// shadow. Everything that reads as "a surface" is one of these.
///
/// In light mode the page and the card are both pure white, so a card is
/// delineated **only** by its hairline and its shadow — which is why neither is
/// optional dressing. Dark mode adds a lightness step and drops most of the
/// shadow's job onto that step.
///
/// ## About [accent]
///
/// A surface gets an ink edge because it is a surface. It gets a *coloured*
/// one only when the colour is carrying information. In the web app this was
/// enforced the hard way: 67 cards wore a 5px cobalt slab, against 3 that meant
/// anything by it, and twenty stacked down a feed stopped reading as emphasis
/// and became texture — drowning the handful of edges that did carry meaning.
/// All 67 became hairlines.
///
/// So before passing [accent], ask whether the colour of that edge tells the
/// reader something the rest of the card does not. "This looks important" is
/// not that. The legitimate cases are page identity ([PageBanner]), state
/// ([PageState]), selection, and generated content.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppShape.space4),
    this.margin,
    this.color,
    this.elevation = SurfaceElevation.md,
    this.accent = SurfaceAccent.none,
    this.accentEdge = SurfaceAccentEdge.left,
    this.accentWidth = AppShape.accentSurface,
    this.onTap,
    this.width,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final SurfaceElevation elevation;
  final SurfaceAccent accent;
  final SurfaceAccentEdge accentEdge;
  final double accentWidth;
  final VoidCallback? onTap;
  final double? width;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hairline = borderColor ?? t.border;

    final accentColor = switch (accent) {
      SurfaceAccent.none => null,
      SurfaceAccent.primary => t.primary,
      SurfaceAccent.destructive => t.destructive,
      SurfaceAccent.success => t.success,
      SurfaceAccent.warning => t.warning,
      SurfaceAccent.info => t.info,
    };

    BorderSide side(SurfaceAccentEdge edge) =>
        accentColor != null && edge == accentEdge
            ? BorderSide(color: accentColor, width: accentWidth)
            : BorderSide(color: hairline, width: AppShape.hairline);

    final content = Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? t.card,
        border: Border(
          top: side(SurfaceAccentEdge.top),
          left: side(SurfaceAccentEdge.left),
          right: side(SurfaceAccentEdge.right),
          bottom: side(SurfaceAccentEdge.bottom),
        ),
        boxShadow: _shadow(context.elevation),
      ),
      child: child,
    );

    final tappable = onTap == null
        ? content
        : _PressScale(onTap: onTap!, child: content);

    return margin == null
        ? tappable
        : Padding(padding: margin!, child: tappable);
  }

  List<BoxShadow> _shadow(AppElevation e) => switch (elevation) {
        SurfaceElevation.none => const [],
        SurfaceElevation.xs => e.xs,
        SurfaceElevation.sm => e.sm,
        SurfaceElevation.md => e.md,
        SurfaceElevation.lg => e.lg,
      };
}

/// The web app's `active:scale-[0.95]`, which every interactive surface there
/// shares. Doing it with a scale rather than a Material ripple keeps the press
/// feedback inside the square silhouette — an ink splash rounds its own
/// corners and reads as a different shape language.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
