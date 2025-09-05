import 'package:flutter/material.dart';
import 'shadcn_colors.dart';

class TailwindBorder {
  TailwindBorder._();

  // Border widths
  static const double none = 0.0;
  static const double xs = 0.5;
  static const double sm = 1.0;
  static const double md = 1.5;
  static const double lg = 2.0;
  static const double xl = 4.0;
  static const double xxl = 8.0;

  // Border radius values (matching Tailwind)
  static const double radiusNone = 0.0;
  static const double radiusSm = 2.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radius2xl = 16.0;
  static const double radius3xl = 24.0;
  static const double radiusFull = 9999.0;

  // Border utilities
  static Border noBorder = Border.all(width: 0, color: Colors.transparent);

  // Basic borders with theme-aware colors
  static Border all(BuildContext context, {double width = sm}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Border.all(
      width: width,
      color: isDark ? ShadCnColors.darkBorder : ShadCnColors.lightBorder,
    );
  }

  static Border top(BuildContext context, {double width = sm}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Border(
      top: BorderSide(
        width: width,
        color: isDark ? ShadCnColors.darkBorder : ShadCnColors.lightBorder,
      ),
    );
  }

  static Border right(BuildContext context, {double width = sm}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Border(
      right: BorderSide(
        width: width,
        color: isDark ? ShadCnColors.darkBorder : ShadCnColors.lightBorder,
      ),
    );
  }

  static Border bottom(BuildContext context, {double width = sm}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Border(
      bottom: BorderSide(
        width: width,
        color: isDark ? ShadCnColors.darkBorder : ShadCnColors.lightBorder,
      ),
    );
  }

  static Border left(BuildContext context, {double width = sm}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Border(
      left: BorderSide(
        width: width,
        color: isDark ? ShadCnColors.darkBorder : ShadCnColors.lightBorder,
      ),
    );
  }

  // Colored borders
  static Border colored(Color color, {double width = sm}) {
    return Border.all(width: width, color: color);
  }

  // Border radius utilities
  static BorderRadius rounded({double radius = radiusMd}) {
    return BorderRadius.circular(radius);
  }

  static BorderRadius roundedTop({double radius = radiusMd}) {
    return BorderRadius.only(
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
  }

  static BorderRadius roundedBottom({double radius = radiusMd}) {
    return BorderRadius.only(
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
  }

  static BorderRadius roundedLeft({double radius = radiusMd}) {
    return BorderRadius.only(
      topLeft: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
    );
  }

  static BorderRadius roundedRight({double radius = radiusMd}) {
    return BorderRadius.only(
      topRight: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
  }

  static BorderRadius roundedTopLeft({double radius = radiusMd}) {
    return BorderRadius.only(topLeft: Radius.circular(radius));
  }

  static BorderRadius roundedTopRight({double radius = radiusMd}) {
    return BorderRadius.only(topRight: Radius.circular(radius));
  }

  static BorderRadius roundedBottomLeft({double radius = radiusMd}) {
    return BorderRadius.only(bottomLeft: Radius.circular(radius));
  }

  static BorderRadius roundedBottomRight({double radius = radiusMd}) {
    return BorderRadius.only(bottomRight: Radius.circular(radius));
  }
}

class TailwindShadow {
  TailwindShadow._();

  // Shadow elevations (matching Tailwind shadow system)
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
      blurRadius: 2.0,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
      blurRadius: 6.0,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
      blurRadius: 4.0,
      offset: Offset(0, 2),
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
      blurRadius: 15.0,
      offset: Offset(0, 10),
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
      blurRadius: 6.0,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x19000000), // rgba(0, 0, 0, 0.1)
      blurRadius: 25.0,
      offset: Offset(0, 20),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
      blurRadius: 10.0,
      offset: Offset(0, 8),
      spreadRadius: -6,
    ),
  ];

  static const List<BoxShadow> xxl = [
    BoxShadow(
      color: Color(0x19000000), // rgba(0, 0, 0, 0.1)
      blurRadius: 50.0,
      offset: Offset(0, 25),
      spreadRadius: -12,
    ),
  ];

  static const List<BoxShadow> inner = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
      blurRadius: 4.0,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Colored shadows
  static List<BoxShadow> colored({
    required Color color,
    double opacity = 0.5,
    double blurRadius = 6.0,
    Offset offset = const Offset(0, 4),
    double spreadRadius = -2,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  // Custom shadow utility
  static List<BoxShadow> custom({
    Color color = const Color(0x1A000000),
    double blurRadius = 6.0,
    Offset offset = const Offset(0, 4),
    double spreadRadius = -2,
  }) {
    return [
      BoxShadow(
        color: color,
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: spreadRadius,
      ),
    ];
  }
}

// Quick access utilities class
class TW {
  TW._();

  // Border widths
  static const double borderNone = TailwindBorder.none;
  static const double borderXs = TailwindBorder.xs;
  static const double borderSm = TailwindBorder.sm;
  static const double borderMd = TailwindBorder.md;
  static const double borderLg = TailwindBorder.lg;
  static const double borderXl = TailwindBorder.xl;
  static const double border2xl = TailwindBorder.xxl;

  // Border radius
  static const double roundedNone = TailwindBorder.radiusNone;
  static const double roundedSm = TailwindBorder.radiusSm;
  static const double roundedMd = TailwindBorder.radiusMd;
  static const double roundedLg = TailwindBorder.radiusLg;
  static const double roundedXl = TailwindBorder.radiusXl;
  static const double rounded2xl = TailwindBorder.radius2xl;
  static const double rounded3xl = TailwindBorder.radius3xl;
  static const double roundedFull = TailwindBorder.radiusFull;

  // Shadows
  static const List<BoxShadow> shadowNone = TailwindShadow.none;
  static const List<BoxShadow> shadowSm = TailwindShadow.sm;
  static const List<BoxShadow> shadowMd = TailwindShadow.md;
  static const List<BoxShadow> shadowLg = TailwindShadow.lg;
  static const List<BoxShadow> shadowXl = TailwindShadow.xl;
  static const List<BoxShadow> shadow2xl = TailwindShadow.xxl;
  static const List<BoxShadow> shadowInner = TailwindShadow.inner;

  // Spacing scale (matching Tailwind)
  static const double space0 = 0;
  static const double space1 = 4; // 0.25rem
  static const double space2 = 8; // 0.5rem
  static const double space3 = 12; // 0.75rem
  static const double space4 = 16; // 1rem
  static const double space5 = 20; // 1.25rem
  static const double space6 = 24; // 1.5rem
  static const double space8 = 32; // 2rem
  static const double space10 = 40; // 2.5rem
  static const double space12 = 48; // 3rem
  static const double space16 = 64; // 4rem
  static const double space20 = 80; // 5rem
  static const double space24 = 96; // 6rem
}
