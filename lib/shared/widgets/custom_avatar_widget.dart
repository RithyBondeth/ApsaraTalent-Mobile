import 'package:apsaratalent_mobile/core/extensions/color_extensions.dart';
import 'package:apsaratalent_mobile/core/extensions/text_extensions.dart';
import 'package:flutter/material.dart';

enum EAvatarSize { small, medium, large, extraLarge, veryLarge }

enum EAvatarBorderRadius { none, sm, md, lg, xl, full }

class CustomAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final String? fallbackText;
  final EAvatarSize size;
  final EAvatarBorderRadius borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const CustomAvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.fallbackText,
    this.size = EAvatarSize.medium,
    this.borderRadius = EAvatarBorderRadius.full,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getAvatarSize();
    final radius = _getBorderRadius(avatarSize);

    Widget avatar = Container(
      height: avatarSize,
      width: avatarSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.muted,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: context.border.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: _buildAvatarContent(context),
      ),
    );

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildAvatarContent(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(context);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(context.primary),
            ),
          );
        },
      );
    }

    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    final fallback = _getFallbackText();

    return Center(
      child: Text(
        fallback,
        style: _getTextStyle(context).copyWith(
          color: textColor ?? context.mutedForeground,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getFallbackText() {
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      return fallbackText!;
    }

    if (name != null && name!.isNotEmpty) {
      final words = name!.trim().split(' ');
      if (words.length >= 2) {
        return '${words[0][0].toUpperCase()}${words[1][0].toUpperCase()}';
      } else if (words.isNotEmpty) {
        return words[0][0].toUpperCase();
      }
    }

    return 'U';
  }

  double _getAvatarSize() {
    switch (size) {
      case EAvatarSize.small:
        return 32;
      case EAvatarSize.medium:
        return 40;
      case EAvatarSize.large:
        return 48;
      case EAvatarSize.extraLarge:
        return 64;
      case EAvatarSize.veryLarge:
        return 72;
    }
  }

  double _getBorderRadius(double avatarSize) {
    switch (borderRadius) {
      case EAvatarBorderRadius.none:
        return 0;
      case EAvatarBorderRadius.sm:
        return 4;
      case EAvatarBorderRadius.md:
        return 8;
      case EAvatarBorderRadius.lg:
        return 12;
      case EAvatarBorderRadius.xl:
        return 16;
      case EAvatarBorderRadius.full:
        return avatarSize / 2;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case EAvatarSize.small:
        return context.labelSmall;
      case EAvatarSize.medium:
        return context.labelMedium;
      case EAvatarSize.large:
        return context.titleMedium;
      case EAvatarSize.extraLarge:
      case EAvatarSize.veryLarge:
        return context.titleLarge;
    }
  }
}
