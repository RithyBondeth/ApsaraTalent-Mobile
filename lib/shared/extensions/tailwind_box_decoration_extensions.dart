import 'package:flutter/material.dart';
import '../themes/tailwind_styles.dart';

// Extension methods for BoxDecoration styling
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