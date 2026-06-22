import 'package:flutter/material.dart';
import '../themes/tailwind_styles.dart';

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
