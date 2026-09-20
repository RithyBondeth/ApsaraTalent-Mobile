import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_tokens.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';

/// The six button variants from the web app, in the same order of precedence.
enum AppButtonVariant {
  /// Filled primary. One per screen, on the screen's main action.
  primary,

  /// Filled destructive, for an action that removes or ends something.
  destructive,

  /// Hairline on the page background.
  outline,

  /// Filled with the quiet neutral surface.
  secondary,

  /// No fill and no edge until pressed.
  ghost,

  /// Reads as a link, not a control.
  link,
}

enum AppButtonSize { sm, md, lg, icon }

/// The app's button.
///
/// Square, like everything else, and it presses with a scale rather than a
/// ripple — a Material ink splash rounds its own corners and fights the
/// silhouette. The press target floors at 44pt even for [AppButtonSize.sm],
/// which is the one place this deliberately departs from the web (`h-10`,
/// 40px): a pointer can hit a 40px control and a thumb reliably cannot.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.fullWidth = false,
    this.loading = false,
  });

  /// An icon-only button. [semanticLabel] is not optional — an icon with no
  /// accessible name is invisible to a screen reader.
  const AppButton.icon({
    super.key,
    required IconData this.icon,
    required String semanticLabel,
    this.onPressed,
    this.variant = AppButtonVariant.ghost,
    this.loading = false,
  })  : label = semanticLabel,
        size = AppButtonSize.icon,
        trailingIcon = null,
        fullWidth = false;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool fullWidth;
  final bool loading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _down = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final style = _styleFor(t, widget.variant);
    final isIconOnly = widget.size == AppButtonSize.icon;

    final height = switch (widget.size) {
      AppButtonSize.sm => AppShape.controlHeightSm,
      AppButtonSize.md => AppShape.controlHeightMd,
      AppButtonSize.lg => AppShape.controlHeightLg,
      AppButtonSize.icon => AppShape.controlHeightMd,
    };

    final horizontal = switch (widget.size) {
      AppButtonSize.sm => AppShape.space3,
      AppButtonSize.md => AppShape.space4,
      AppButtonSize.lg => AppShape.space8,
      AppButtonSize.icon => 0.0,
    };

    Widget content;
    if (widget.loading) {
      content = SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(style.foreground),
        ),
      );
    } else if (isIconOnly) {
      content = Icon(widget.icon, size: 20, color: style.foreground);
    } else {
      content = Row(
        mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 16, color: style.foreground),
            const SizedBox(width: AppShape.space2),
          ],
          Flexible(
            child: Text(
              widget.label,
              overflow: TextOverflow.ellipsis,
              style: widget.variant == AppButtonVariant.link
                  ? AppTypography.button.copyWith(
                      color: style.foreground,
                      decoration: TextDecoration.underline,
                      decorationColor: style.foreground,
                    )
                  : AppTypography.button.copyWith(color: style.foreground),
            ),
          ),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: AppShape.space2),
            Icon(widget.trailingIcon, size: 16, color: style.foreground),
          ],
        ],
      );
    }

    final button = AnimatedOpacity(
      // `disabled:opacity-50`
      opacity: _enabled ? 1 : 0.5,
      duration: const Duration(milliseconds: 150),
      child: AnimatedScale(
        // `active:scale-[0.95]`
        scale: _down && _enabled ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: height,
          width: isIconOnly ? height : (widget.fullWidth ? double.infinity : null),
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          // Only centre when the box is actually wider than its content. A
          // Container with an `alignment` and no width expands to fill its
          // loose constraints, so setting this unconditionally made every
          // button full-width and `fullWidth: false` a no-op.
          alignment: widget.fullWidth || isIconOnly ? Alignment.center : null,
          decoration: BoxDecoration(
            color: _down && _enabled && style.pressedFill != null
                ? style.pressedFill
                : style.fill,
            border: style.border == null
                ? null
                : Border.all(color: style.border!, width: AppShape.hairline),
          ),
          child: content,
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.size == AppButtonSize.icon ? widget.label : null,
      child: GestureDetector(
        onTap: _enabled ? widget.onPressed : null,
        onTapDown: _enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: _enabled ? () => setState(() => _down = false) : null,
        behavior: HitTestBehavior.opaque,
        child: button,
      ),
    );
  }

  _ButtonStyle _styleFor(AppTokens t, AppButtonVariant variant) =>
      switch (variant) {
        AppButtonVariant.primary => _ButtonStyle(
            fill: t.primary,
            foreground: t.primaryForeground,
            pressedFill: t.primary.withValues(alpha: 0.9),
          ),
        AppButtonVariant.destructive => _ButtonStyle(
            fill: t.destructive,
            foreground: t.destructiveForeground,
            pressedFill: t.destructive.withValues(alpha: 0.9),
          ),
        AppButtonVariant.outline => _ButtonStyle(
            fill: t.background,
            foreground: t.foreground,
            // `border-input`, not `border-border`: this is a control boundary,
            // and that token is the one that holds 3:1.
            border: t.input,
            pressedFill: t.accent,
          ),
        AppButtonVariant.secondary => _ButtonStyle(
            fill: t.secondary,
            foreground: t.secondaryForeground,
            pressedFill: t.secondary.withValues(alpha: 0.8),
          ),
        AppButtonVariant.ghost => _ButtonStyle(
            fill: Colors.transparent,
            foreground: t.foreground,
            pressedFill: t.accent,
          ),
        AppButtonVariant.link => _ButtonStyle(
            fill: Colors.transparent,
            foreground: t.primary,
          ),
      };
}

class _ButtonStyle {
  const _ButtonStyle({
    required this.fill,
    required this.foreground,
    this.border,
    this.pressedFill,
  });

  final Color fill;
  final Color foreground;
  final Color? border;
  final Color? pressedFill;
}
