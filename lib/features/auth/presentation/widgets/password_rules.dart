import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/validators/password_validator.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The new-password requirements, ticked off as they are met.
///
/// Showing the list up front beats a single error after submit: the API's rule
/// has five parts, and "password is not strong enough" names none of them.
class PasswordRules extends StatelessWidget {
  const PasswordRules({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppShape.space4,
      runSpacing: AppShape.space1,
      children: [
        for (final rule in PasswordValidator.strongRules)
          _Rule(label: rule.label, met: rule.test(password)),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.label, required this.met});

  final String label;
  final bool met;


  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // Met is a state (success); unmet is neutral rather than red — nothing is
    // wrong with a password the user hasn't finished typing.
    final color = met ? t.successAccent : t.mutedForeground;
    return Semantics(
      label: '$label, ${met ? 'met' : 'not met'}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(met ? LucideIcons.circleCheck : LucideIcons.circle, size: 14, color: color),
          const SizedBox(width: AppShape.space1),
          Text(label, style: AppTypography.tiny.copyWith(color: color)),
        ],
      ),
    );
  }
}
