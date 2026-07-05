import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class AppFonts {
  AppFonts._();

  // Ubuntu font variations
  static TextStyle ubuntu({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.ubuntu(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Predefined text styles
  static TextStyle get headingLarge => GoogleFonts.ubuntu(
        fontSize: 32,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headingMedium => GoogleFonts.ubuntu(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headingSmall => GoogleFonts.ubuntu(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleLarge => GoogleFonts.ubuntu(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get titleMedium => GoogleFonts.ubuntu(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get titleSmall => GoogleFonts.ubuntu(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyLarge => GoogleFonts.ubuntu(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.ubuntu(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.ubuntu(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelLarge => GoogleFonts.ubuntu(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelMedium => GoogleFonts.ubuntu(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelSmall => GoogleFonts.ubuntu(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );
}
