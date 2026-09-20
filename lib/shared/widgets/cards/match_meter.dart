import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';

/// How well something matches the viewer, 0–100.
///
/// Drawn as a neutral track with a primary fill, and labelled with the number.
/// It deliberately does **not** map the score onto the status colours: a 64%
/// match is not a warning and a 92% is not a success. Spending amber on a
/// middling match is exactly the borrowing that stops a real warning from
/// standing out elsewhere in the app.
///
/// The web app's equivalent shipped raw hex through an inline style, which put
/// it outside every colour gate and left it at 2.15–3.76:1 in light mode while
/// the ratchets reported clean. The colours here are tokens, so it follows the
/// theme and is covered by whatever gates the tokens.
class MatchMeter extends StatelessWidget {
  const MatchMeter({super.key, required this.score, this.showLabel = true});

  /// 0–100.
  final int score;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fraction = (score.clamp(0, 100)) / 100;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 56,
          child: Stack(
            children: [
              Container(height: 6, color: t.muted),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(height: 6, color: t.primary),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: AppShape.space2),
          Text(
            '$score% match',
            style: AppTypography.tiny.copyWith(
              color: t.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
