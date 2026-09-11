import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';
import 'package:apsaratalent_mobile/core/extensions/context_extensions.dart';

enum AppAvatarSize { xs, sm, md, lg, xl }

/// An avatar. Round — one of the three things in this app that is
/// (avatars, dots, pills), and the roundness is what marks it as a person or
/// an organisation rather than a surface.
///
/// Falls back to initials, and falls back again to a single glyph when there is
/// only one word. A network image that fails resolves to the same initials
/// rather than a broken-image box.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.md,
    this.onTap,
    this.squared = false,
  });

  final String? imageUrl;
  final String? name;
  final AppAvatarSize size;
  final VoidCallback? onTap;

  /// Companies read better as a square tile than a circle — a logo is not a
  /// face. Set this for organisation avatars.
  final bool squared;

  double get _dimension => switch (size) {
        AppAvatarSize.xs => 28,
        AppAvatarSize.sm => 36,
        AppAvatarSize.md => 44,
        AppAvatarSize.lg => 56,
        AppAvatarSize.xl => 72,
      };

  TextStyle get _textStyle => switch (size) {
        AppAvatarSize.xs => AppTypography.tiny,
        AppAvatarSize.sm => AppTypography.tag,
        AppAvatarSize.md => AppTypography.label,
        AppAvatarSize.lg => AppTypography.h4,
        AppAvatarSize.xl => AppTypography.h3,
      };

  String get _initials {
    final source = name?.trim() ?? '';
    if (source.isEmpty) return '?';
    final words = source.split(RegExp(r'\s+'));
    if (words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = squared ? AppShape.radius : AppShape.pill;

    Widget avatar = Container(
      height: _dimension,
      width: _dimension,
      decoration: BoxDecoration(
        color: t.muted,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: t.border, width: AppShape.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: _dimension,
              height: _dimension,
              errorBuilder: (_, __, ___) => _fallback(context),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _fallback(context),
            )
          : _fallback(context),
    );

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  Widget _fallback(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Text(
        _initials,
        style: _textStyle.copyWith(
          color: t.mutedForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
