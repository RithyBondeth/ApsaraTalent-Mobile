import 'package:flutter/material.dart';
import '../extensions/color_extensions.dart';
import '../extensions/text_extensions.dart';
import '../themes/tailwind_styles.dart';

class CustomDialog extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? content;
  final List<Widget>? actions;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final double? width;
  final double? height;
  final EdgeInsets? contentPadding;

  const CustomDialog({
    super.key,
    this.title,
    this.description,
    this.content,
    this.actions,
    this.showCloseButton = true,
    this.onClose,
    this.width,
    this.height,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: width ?? 400,
        height: height,
        constraints: const BoxConstraints(
          maxWidth: 500,
          minWidth: 300,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(TW.roundedLg),
          boxShadow: TW.shadowXl,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null || showCloseButton) _buildHeader(context),
            if (content != null || description != null) _buildContent(context),
            if (actions != null && actions!.isNotEmpty) _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: context.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (showCloseButton)
            IconButton(
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              style: IconButton.styleFrom(
                foregroundColor: context.mutedForeground,
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Flexible(
      child: Container(
        padding: contentPadding ?? const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description != null)
              Text(
                description!,
                style: context.bodyMedium.copyWith(
                  color: context.mutedForeground,
                ),
              ),
            if (description != null && content != null)
              const SizedBox(height: 16),
            if (content != null) content!,
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (int i = 0; i < actions!.length; i++) ...[
            actions![i],
            if (i < actions!.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

// Dialog Header Component
class DialogHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;

  const DialogHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: context.bodySmall.copyWith(
                      color: context.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!,
            ),
        ],
      ),
    );
  }
}

// Dialog Content Component
class DialogContent extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const DialogContent({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
      child: child,
    );
  }
}

// Dialog Footer Component
class DialogFooter extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment alignment;
  final EdgeInsets? padding;

  const DialogFooter({
    super.key,
    required this.children,
    this.alignment = MainAxisAlignment.end,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

// Utility functions for showing dialogs
class DialogUtils {
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget dialog,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      builder: (context) => dialog,
    );
  }

  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    bool isDestructive = false,
  }) {
    return showCustomDialog<bool>(
      context: context,
      dialog: CustomDialog(
        title: title,
        description: message,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(color: context.mutedForeground),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive 
                  ? context.destructive 
                  : (confirmColor ?? context.primary),
              foregroundColor: isDestructive 
                  ? context.destructiveForeground 
                  : context.primaryForeground,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    Widget? icon,
  }) {
    return showCustomDialog(
      context: context,
      dialog: CustomDialog(
        title: title,
        description: message,
        content: icon != null 
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(height: 16),
                ],
              )
            : null,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}