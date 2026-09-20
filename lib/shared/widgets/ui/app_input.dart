import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';

/// The app's text field.
///
/// Three states are drawn on the boundary, in this order of precedence: error
/// beats focus beats rest. The resting edge is `input` rather than `border` —
/// they are deliberately different tokens, `border` being decorative at 1.45:1
/// while `input` carries the 3:1 that WCAG 1.4.11 asks of a control boundary.
/// Collapsing them is how the web app's login fields once ended up at 1.25:1
/// against the page.
///
/// The focus ring is drawn as a second, outer box rather than a thicker border
/// so that gaining focus does not change the field's size and shove the rest of
/// the form down a pixel.
class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.autofillHints,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    // Only dispose a node this widget created; one passed in belongs to the
    // caller and may outlive the field.
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final multiline = widget.maxLines > 1;

    final edge = hasError
        ? t.destructive
        : _focused
            ? t.ring
            : t.input;

    final ringColor = hasError ? t.destructive : t.ring;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTypography.label.copyWith(color: t.foreground),
          ),
          const SizedBox(height: AppShape.space2),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            // The 3px focus ring, drawn outside the field's own box so focus
            // never changes the layout.
            border: Border.all(
              color: _focused
                  ? ringColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: Container(
            height: multiline ? null : AppShape.fieldHeight,
            constraints: multiline
                ? const BoxConstraints(minHeight: AppShape.fieldHeight)
                : null,
            padding: const EdgeInsets.symmetric(horizontal: AppShape.space3),
            decoration: BoxDecoration(
              color: widget.enabled ? t.background : t.muted,
              border: Border.all(color: edge, width: AppShape.hairline),
            ),
            child: Row(
              crossAxisAlignment: multiline
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                if (widget.prefixIcon != null) ...[
                  Padding(
                    padding: EdgeInsets.only(top: multiline ? 14 : 0),
                    child: Icon(
                      widget.prefixIcon,
                      size: 18,
                      color: t.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: AppShape.space2),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    enabled: widget.enabled,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    maxLines: widget.maxLines,
                    minLines: widget.minLines,
                    inputFormatters: widget.inputFormatters,
                    autofillHints: widget.autofillHints,
                    cursorColor: t.primary,
                    style: AppTypography.field.copyWith(
                      color: widget.enabled ? t.foreground : t.mutedForeground,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: multiline ? AppShape.space4 : 0,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: widget.hintText,
                      hintStyle: AppTypography.small.copyWith(
                        color: t.mutedForeground.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                if (widget.suffixIcon != null) ...[
                  const SizedBox(width: AppShape.space2),
                  GestureDetector(
                    onTap: widget.onSuffixTap,
                    child: Padding(
                      padding: EdgeInsets.only(top: multiline ? 14 : 0),
                      child: Icon(
                        widget.suffixIcon,
                        size: 18,
                        color: t.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppShape.space1),
          Text(
            widget.errorText!,
            style: AppTypography.tiny.copyWith(color: t.destructive),
          ),
        ],
      ],
    );
  }
}
