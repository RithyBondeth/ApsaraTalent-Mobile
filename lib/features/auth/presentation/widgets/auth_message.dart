import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum EAuthMessageKind { error, success, info }

/// The result of an auth action, drawn on the status tokens — a failed code is
/// a state, so it takes the status family that carries severity.
class AuthMessage extends StatelessWidget {
  const AuthMessage({super.key, required this.kind, required this.message});

  const AuthMessage.error(this.message, {super.key}) : kind = EAuthMessageKind.error;
  const AuthMessage.success(this.message, {super.key}) : kind = EAuthMessageKind.success;
  const AuthMessage.info(this.message, {super.key}) : kind = EAuthMessageKind.info;

  final EAuthMessageKind kind;
  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (fill, edge, ink, icon) = switch (kind) {
      EAuthMessageKind.error => (
          t.destructiveSubtle,
          t.destructiveBorder,
          t.destructiveAccent,
          LucideIcons.triangleAlert,
        ),
      EAuthMessageKind.success => (
          t.successSubtle,
          t.successBorder,
          t.successAccent,
          LucideIcons.circleCheck,
        ),
      EAuthMessageKind.info => (
          t.infoSubtle,
          t.infoBorder,
          t.infoAccent,
          LucideIcons.info,
        ),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppShape.space3),
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: edge, width: AppShape.hairline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: ink),
            const SizedBox(width: AppShape.space2),
            Expanded(
              child: Text(
                message,
                style: AppTypography.small.copyWith(color: ink, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
