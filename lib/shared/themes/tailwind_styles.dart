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

// Widget extension for quick styling
extension TailwindWidget on Widget {
  Widget tw({
    Border? border,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Color? backgroundColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? width,
    double? height,
    AlignmentGeometry? alignment,
  }) {
    Widget result = this;

    // Apply container with styling
    result = Container(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      alignment: alignment,
      decoration: BoxDecoration(
        border: border,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        color: backgroundColor,
      ),
      child: result,
    );

    return result;
  }

  // Border utilities
  Widget border(BuildContext context, {double width = TailwindBorder.sm}) {
    return tw(border: TailwindBorder.all(context, width: width));
  }

  Widget borderTop(BuildContext context, {double width = TailwindBorder.sm}) {
    return tw(border: TailwindBorder.top(context, width: width));
  }

  Widget borderRight(BuildContext context, {double width = TailwindBorder.sm}) {
    return tw(border: TailwindBorder.right(context, width: width));
  }

  Widget borderBottom(BuildContext context,
      {double width = TailwindBorder.sm}) {
    return tw(border: TailwindBorder.bottom(context, width: width));
  }

  Widget borderLeft(BuildContext context, {double width = TailwindBorder.sm}) {
    return tw(border: TailwindBorder.left(context, width: width));
  }

  Widget borderColored(Color color, {double width = TailwindBorder.sm}) {
    return tw(border: TailwindBorder.colored(color, width: width));
  }

  // Border radius utilities
  Widget rounded({double radius = TailwindBorder.radiusMd}) {
    return tw(borderRadius: TailwindBorder.rounded(radius: radius));
  }

  Widget roundedSm() {
    return tw(
        borderRadius: TailwindBorder.rounded(radius: TailwindBorder.radiusSm));
  }

  Widget roundedLg() {
    return tw(
        borderRadius: TailwindBorder.rounded(radius: TailwindBorder.radiusLg));
  }

  Widget roundedXl() {
    return tw(
        borderRadius: TailwindBorder.rounded(radius: TailwindBorder.radiusXl));
  }

  Widget rounded2xl() {
    return tw(
        borderRadius: TailwindBorder.rounded(radius: TailwindBorder.radius2xl));
  }

  Widget rounded3xl() {
    return tw(
        borderRadius: TailwindBorder.rounded(radius: TailwindBorder.radius3xl));
  }

  Widget roundedFull() {
    return tw(
        borderRadius:
            TailwindBorder.rounded(radius: TailwindBorder.radiusFull));
  }

  Widget roundedTop({double radius = TailwindBorder.radiusMd}) {
    return tw(borderRadius: TailwindBorder.roundedTop(radius: radius));
  }

  Widget roundedBottom({double radius = TailwindBorder.radiusMd}) {
    return tw(borderRadius: TailwindBorder.roundedBottom(radius: radius));
  }

  Widget roundedLeft({double radius = TailwindBorder.radiusMd}) {
    return tw(borderRadius: TailwindBorder.roundedLeft(radius: radius));
  }

  Widget roundedRight({double radius = TailwindBorder.radiusMd}) {
    return tw(borderRadius: TailwindBorder.roundedRight(radius: radius));
  }

  // Shadow utilities
  Widget shadowNone() {
    return tw(boxShadow: TailwindShadow.none);
  }

  Widget shadowSm() {
    return tw(boxShadow: TailwindShadow.sm);
  }

  Widget shadowMd() {
    return tw(boxShadow: TailwindShadow.md);
  }

  Widget shadowLg() {
    return tw(boxShadow: TailwindShadow.lg);
  }

  Widget shadowXl() {
    return tw(boxShadow: TailwindShadow.xl);
  }

  Widget shadow2xl() {
    return tw(boxShadow: TailwindShadow.xxl);
  }

  Widget shadowInner() {
    return tw(boxShadow: TailwindShadow.inner);
  }

  Widget shadowColored({
    required Color color,
    double opacity = 0.5,
    double blurRadius = 6.0,
    Offset offset = const Offset(0, 4),
    double spreadRadius = -2,
  }) {
    return tw(
      boxShadow: TailwindShadow.colored(
        color: color,
        opacity: opacity,
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: spreadRadius,
      ),
    );
  }

  // Padding utilities
  Widget p(double padding) {
    return tw(padding: EdgeInsets.all(padding));
  }

  Widget px(double padding) {
    return tw(padding: EdgeInsets.symmetric(horizontal: padding));
  }

  Widget py(double padding) {
    return tw(padding: EdgeInsets.symmetric(vertical: padding));
  }

  Widget pt(double padding) {
    return tw(padding: EdgeInsets.only(top: padding));
  }

  Widget pr(double padding) {
    return tw(padding: EdgeInsets.only(right: padding));
  }

  Widget pb(double padding) {
    return tw(padding: EdgeInsets.only(bottom: padding));
  }

  Widget pl(double padding) {
    return tw(padding: EdgeInsets.only(left: padding));
  }

  // Margin utilities
  Widget m(double margin) {
    return tw(margin: EdgeInsets.all(margin));
  }

  Widget mx(double margin) {
    return tw(margin: EdgeInsets.symmetric(horizontal: margin));
  }

  Widget my(double margin) {
    return tw(margin: EdgeInsets.symmetric(vertical: margin));
  }

  Widget mt(double margin) {
    return tw(margin: EdgeInsets.only(top: margin));
  }

  Widget mr(double margin) {
    return tw(margin: EdgeInsets.only(right: margin));
  }

  Widget mb(double margin) {
    return tw(margin: EdgeInsets.only(bottom: margin));
  }

  Widget ml(double margin) {
    return tw(margin: EdgeInsets.only(left: margin));
  }

  // Size utilities
  Widget w(double width) {
    return tw(width: width);
  }

  Widget h(double height) {
    return tw(height: height);
  }

  Widget size(double size) {
    return tw(width: size, height: size);
  }

  // Background color
  Widget bg(Color color) {
    return tw(backgroundColor: color);
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

// Extension methods for easier usage
extension TailwindBoxDecoration on BoxDecoration {
  // Border utilities
  BoxDecoration border(BuildContext context,
      {double width = TailwindBorder.sm}) {
    return copyWith(border: TailwindBorder.all(context, width: width));
  }

  BoxDecoration borderTop(BuildContext context,
      {double width = TailwindBorder.sm}) {
    return copyWith(border: TailwindBorder.top(context, width: width));
  }

  BoxDecoration borderRight(BuildContext context,
      {double width = TailwindBorder.sm}) {
    return copyWith(border: TailwindBorder.right(context, width: width));
  }

  BoxDecoration borderBottom(BuildContext context,
      {double width = TailwindBorder.sm}) {
    return copyWith(border: TailwindBorder.bottom(context, width: width));
  }

  BoxDecoration borderLeft(BuildContext context,
      {double width = TailwindBorder.sm}) {
    return copyWith(border: TailwindBorder.left(context, width: width));
  }

  BoxDecoration borderColored(Color color, {double width = TailwindBorder.sm}) {
    return copyWith(border: TailwindBorder.colored(color, width: width));
  }

  // Border radius utilities
  BoxDecoration rounded({double radius = TailwindBorder.radiusMd}) {
    return copyWith(borderRadius: TailwindBorder.rounded(radius: radius));
  }

  BoxDecoration roundedTop({double radius = TailwindBorder.radiusMd}) {
    return copyWith(borderRadius: TailwindBorder.roundedTop(radius: radius));
  }

  BoxDecoration roundedBottom({double radius = TailwindBorder.radiusMd}) {
    return copyWith(borderRadius: TailwindBorder.roundedBottom(radius: radius));
  }

  BoxDecoration roundedLeft({double radius = TailwindBorder.radiusMd}) {
    return copyWith(borderRadius: TailwindBorder.roundedLeft(radius: radius));
  }

  BoxDecoration roundedRight({double radius = TailwindBorder.radiusMd}) {
    return copyWith(borderRadius: TailwindBorder.roundedRight(radius: radius));
  }

  // Shadow utilities
  BoxDecoration shadowNone() {
    return copyWith(boxShadow: TailwindShadow.none);
  }

  BoxDecoration shadowSm() {
    return copyWith(boxShadow: TailwindShadow.sm);
  }

  BoxDecoration shadowMd() {
    return copyWith(boxShadow: TailwindShadow.md);
  }

  BoxDecoration shadowLg() {
    return copyWith(boxShadow: TailwindShadow.lg);
  }

  BoxDecoration shadowXl() {
    return copyWith(boxShadow: TailwindShadow.xl);
  }

  BoxDecoration shadow2xl() {
    return copyWith(boxShadow: TailwindShadow.xxl);
  }

  BoxDecoration shadowInner() {
    return copyWith(boxShadow: TailwindShadow.inner);
  }

  BoxDecoration shadowColored({
    required Color color,
    double opacity = 0.5,
    double blurRadius = 6.0,
    Offset offset = const Offset(0, 4),
    double spreadRadius = -2,
  }) {
    return copyWith(
      boxShadow: TailwindShadow.colored(
        color: color,
        opacity: opacity,
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: spreadRadius,
      ),
    );
  }
}
