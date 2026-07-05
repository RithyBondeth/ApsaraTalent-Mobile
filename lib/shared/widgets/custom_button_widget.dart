import 'package:apsaratalent_mobile/core/extensions/color_extensions.dart';
import 'package:apsaratalent_mobile/core/extensions/text_extensions.dart';
import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, outline, ghost }

enum ButtonSize { small, medium, large }

enum IconPosition { before, after }

class CustomButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;
  final Widget? icon;
  final IconPosition iconPosition;
  final bool loading;

  const CustomButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.fullWidth = true,
    this.icon,
    this.iconPosition = IconPosition.before,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(context),
          foregroundColor: _getForegroundColor(context),
          disabledBackgroundColor: _getBackgroundColor(context).withAlpha(200),
          disabledForegroundColor: _getForegroundColor(context).withAlpha(200),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: _getBorderSide(context),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(),
            vertical: _getVerticalPadding(),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getForegroundColor(context),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildRowChildren(context),
              ),
      ),
    );
  }

  List<Widget> _buildRowChildren(BuildContext context) {
    final iconWidget = icon != null
        ? IconTheme(
            data: IconThemeData(
              color: _getForegroundColor(context),
            ),
            child: icon!,
          )
        : null;

    final textWidget = Text(
      text,
      style: _getTextStyle(context).copyWith(
        color: _getForegroundColor(context),
      ),
    );

    if (iconWidget == null) {
      return [textWidget];
    }

    if (iconPosition == IconPosition.before) {
      return [
        iconWidget,
        const SizedBox(width: 8),
        textWidget,
      ];
    } else {
      return [
        textWidget,
        const SizedBox(width: 8),
        iconWidget,
      ];
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return context.primary;
      case ButtonVariant.secondary:
        return context.secondary;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return context.primaryForeground;
      case ButtonVariant.secondary:
        return context.secondaryForeground;
      case ButtonVariant.outline:
        return context.primary;
      case ButtonVariant.ghost:
        return context.primary;
    }
  }

  BorderSide _getBorderSide(BuildContext context) {
    switch (variant) {
      case ButtonVariant.outline:
        return BorderSide(color: context.border, width: 1);
      default:
        return BorderSide.none;
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 48;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case ButtonSize.small:
        return 6;
      case ButtonSize.medium:
        return 8;
      case ButtonSize.large:
        return 12;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle =
        size == ButtonSize.small ? context.labelSmall : context.labelMedium;

    return baseStyle.copyWith(
      fontWeight: FontWeight.w500,
    );
  }
}
