import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:flutter/material.dart';

/// "Step 2 of 3" with a segmented bar — where the user is in signup.
class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      label: 'Step $step of $total',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP $step OF $total',
            style: AppTypography.eyebrow.copyWith(color: t.mutedForeground),
          ),
          const SizedBox(height: AppShape.space2),
          Row(
            children: [
              for (var i = 1; i <= total; i++) ...[
                Expanded(
                  child: Container(height: 4, color: i <= step ? t.primary : t.muted),
                ),
                if (i < total) const SizedBox(width: AppShape.space1),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
