import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';

/// A neutral label chip: skills, career scopes, languages, open-position
/// titles.
///
/// **It is neutral, full stop.** The web version used to hash the label's
/// character codes into one of the six categorical hues, which gave "Python"
/// indigo and "React" orange for no reason a reader could follow — and worse,
/// it collided with the hues that *do* mean something, so a skill that hashed
/// to pink was the same fill and text as a benefit chip. Colour on a label now
/// means something, or the label has no colour.
///
/// If you want a coloured chip, the question is whether the colour is carrying
/// information. If it names a *kind*, use [AppCategoryChip]. If it names a
/// *state*, use [AppStatusPill]. If neither, it is this.
class AppTag extends StatelessWidget {
  const AppTag({super.key, required this.label, this.icon, this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppShape.space3,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: t.muted.withValues(alpha: 0.5),
          border: Border.all(color: t.border, width: AppShape.hairline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: t.foreground.withValues(alpha: 0.75)),
              const SizedBox(width: AppShape.space1),
            ],
            Text(
              label,
              style: AppTypography.tag.copyWith(
                color: t.foreground.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
