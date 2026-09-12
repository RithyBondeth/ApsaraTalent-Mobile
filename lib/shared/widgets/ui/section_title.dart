import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';

/// A heading for a band of content inside a page.
///
/// It is deliberately quieter than [PageBanner]'s title: one page-level
/// headline, then everything under it steps down. An optional [action] sits on
/// the right for "see all"-style links.
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.h4.copyWith(color: t.foreground),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppShape.space1),
                Text(
                  subtitle!,
                  style: AppTypography.tiny.copyWith(color: t.mutedForeground),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: AppShape.space3),
              child: Text(
                actionLabel!,
                style: AppTypography.button.copyWith(color: t.primary),
              ),
            ),
          ),
      ],
    );
  }
}

/// An icon and a short piece of metadata — a location, a salary band, a posting
/// date. Neutral by design; if the value carries a state or a kind, it wants a
/// pill or a chip instead.
class MetaChip extends StatelessWidget {
  const MetaChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: t.mutedForeground),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.tiny.copyWith(color: t.mutedForeground),
          ),
        ),
      ],
    );
  }
}
