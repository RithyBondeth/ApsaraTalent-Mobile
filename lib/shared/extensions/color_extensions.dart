import 'package:apsaratalent_mobile/shared/themes/shadcn_colors.dart';
import 'package:flutter/material.dart';

extension ShadCnColorExtensions on BuildContext {
  // Get the color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Get brightness
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Shadcn-style color getters
  Color get background =>
      isDark ? ShadCnColors.darkBackground : ShadCnColors.lightBackground;
  Color get foreground =>
      isDark ? ShadCnColors.darkForeground : ShadCnColors.lightForeground;
  Color get card => isDark ? ShadCnColors.darkCard : ShadCnColors.lightCard;
  Color get cardForeground => isDark
      ? ShadCnColors.darkCardForeground
      : ShadCnColors.lightCardForeground;
  Color get popover =>
      isDark ? ShadCnColors.darkPopover : ShadCnColors.lightPopover;
  Color get popoverForeground => isDark
      ? ShadCnColors.darkPopoverForeground
      : ShadCnColors.lightPopoverForeground;
  Color get primary =>
      isDark ? ShadCnColors.darkPrimary : ShadCnColors.lightPrimary;
  Color get primaryForeground => isDark
      ? ShadCnColors.darkPrimaryForeground
      : ShadCnColors.lightPrimaryForeground;
  Color get secondary =>
      isDark ? ShadCnColors.darkSecondary : ShadCnColors.lightSecondary;
  Color get secondaryForeground => isDark
      ? ShadCnColors.darkSecondaryForeground
      : ShadCnColors.lightSecondaryForeground;
  Color get muted => isDark ? ShadCnColors.darkMuted : ShadCnColors.lightMuted;
  Color get mutedForeground => isDark
      ? ShadCnColors.darkMutedForeground
      : ShadCnColors.lightMutedForeground;
  Color get accent =>
      isDark ? ShadCnColors.darkAccent : ShadCnColors.lightAccent;
  Color get accentForeground => isDark
      ? ShadCnColors.darkAccentForeground
      : ShadCnColors.lightAccentForeground;
  Color get destructive =>
      isDark ? ShadCnColors.darkDestructive : ShadCnColors.lightDestructive;
  Color get destructiveForeground => isDark
      ? ShadCnColors.darkDestructiveForeground
      : ShadCnColors.lightDestructiveForeground;
  Color get border =>
      isDark ? ShadCnColors.darkBorder : ShadCnColors.lightBorder;
  Color get input => isDark ? ShadCnColors.darkInput : ShadCnColors.lightInput;
  Color get ring => isDark ? ShadCnColors.darkRing : ShadCnColors.lightRing;
}
