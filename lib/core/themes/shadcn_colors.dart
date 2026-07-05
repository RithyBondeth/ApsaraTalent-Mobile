import 'package:flutter/material.dart';

class ShadCnColors {
  ShadCnColors._();

  static Color hslToColor(double h, double s, double l) {
    return HSLColor.fromAHSL(1.0, h, s / 100, l / 100).toColor();
  }

  // Light theme colors (converted from CSS variables)
  static const Color lightBackground = Color(0xFFFFFFFF); // 0 0% 100%
  static const Color lightForeground = Color(0xFF0A0A0A); // 0 0% 3.9%
  static const Color lightCard = Color(0xFFFFFFFF); // 0 0% 100%
  static const Color lightCardForeground = Color(0xFF0A0A0A); // 0 0% 3.9%
  static const Color lightPopover = Color(0xFFFFFFFF); // 0 0% 100%
  static const Color lightPopoverForeground = Color(0xFF0A0A0A); // 0 0% 3.9%
  static const Color lightPrimary = Color(0xFF171717); // 0 0% 9%
  static const Color lightPrimaryForeground = Color(0xFFFAFAFA); // 0 0% 98%
  static const Color lightSecondary = Color(0xFFF5F5F5); // 0 0% 96.1%
  static const Color lightSecondaryForeground = Color(0xFF171717); // 0 0% 9%
  static const Color lightMuted = Color(0xFFF5F5F5); // 0 0% 96.1%
  static const Color lightMutedForeground = Color(0xFF737373); // 0 0% 45.1%
  static const Color lightAccent = Color(0xFFF5F5F5); // 0 0% 96.1%
  static const Color lightAccentForeground = Color(0xFF171717); // 0 0% 9%
  static const Color lightDestructive = Color(0xFFEF4444); // 0 84.2% 60.2%
  static const Color lightDestructiveForeground = Color(0xFFFAFAFA); // 0 0% 98%
  static const Color lightBorder = Color(0xFFE5E5E5); // 0 0% 89.8%
  static const Color lightInput = Color(0xFFE5E5E5); // 0 0% 89.8%
  static const Color lightRing = Color(0xFF0A0A0A); // 0 0% 3.9%

  // Dark theme colors (converted from CSS variables)
  static const Color darkBackground = Color(0xFF0A0A0A); // 0 0% 3.9%
  static const Color darkForeground = Color(0xFFFAFAFA); // 0 0% 98%
  static const Color darkCard = Color(0xFF0A0A0A); // 0 0% 3.9%
  static const Color darkCardForeground = Color(0xFFFAFAFA); // 0 0% 98%
  static const Color darkPopover = Color(0xFF0A0A0A); // 0 0% 3.9%
  static const Color darkPopoverForeground = Color(0xFFFAFAFA); // 0 0% 98%
  static const Color darkPrimary = Color(0xFFFAFAFA); // 0 0% 98%
  static const Color darkPrimaryForeground = Color(0xFF171717); // 0 0% 9%
  static const Color darkSecondary = Color(0xFF262626); // 0 0% 14.9%
  static const Color darkSecondaryForeground = Color(0xFFFAFAFA); // 0 0% 98%
  static const Color darkMuted = Color(0xFF262626); // 0 0% 14.9%
  static const Color darkMutedForeground = Color(0xFFA3A3A3); // 0 0% 63.9%
  static const Color darkAccent = Color(0xFF262626); // 0 0% 14.9%
  static const Color darkAccentForeground = Color(0xFFFAFAFA); // 0 0% 98%
  static const Color darkDestructive = Color(0xFF7F1D1D); // 0 62.8% 30.6%
  static const Color darkDestructiveForeground = Color(0xFFFAFAFA); // 0 0% 98%
  static const Color darkBorder = Color(0xFF262626); // 0 0% 14.9%
  static const Color darkInput = Color(0xFF262626); // 0 0% 14.9%
  static const Color darkRing = Color(0xFFD4D4D4); // 0 0% 83.1%

  // Chart colors
  static const Color chart1 = Color(0xFFE76E50); // 12 76% 61%
  static const Color chart2 = Color(0xFF2A9D8F); // 173 58% 39%
  static const Color chart3 = Color(0xFF264653); // 197 37% 24%
  static const Color chart4 = Color(0xFFE9C46A); // 43 74% 66%
  static const Color chart5 = Color(0xFFF4A261); // 27 87% 67%
}
