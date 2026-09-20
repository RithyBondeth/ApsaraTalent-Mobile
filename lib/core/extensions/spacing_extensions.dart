import 'package:flutter/material.dart';

/// Padding sugar, kept because it reads well in deeply nested build methods.
///
/// This is all that survives of a Tailwind-shim layer that also carried
/// `rounded2xl()`, `shadowMd()` and a soft-blur shadow scale. Those were a
/// second design system running beside the tokens — and one that disagreed
/// with it, since the app is square with hard offset shadows. Spacing has no
/// such conflict, so the padding helpers stayed and the rest went.
///
/// Pass values from `AppShape.space*` rather than loose numbers.
extension WidgetSpacing on Widget {
  Widget p(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  Widget px(double value) => Padding(
        padding: EdgeInsets.symmetric(horizontal: value),
        child: this,
      );

  Widget py(double value) => Padding(
        padding: EdgeInsets.symmetric(vertical: value),
        child: this,
      );

  Widget pad({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
        child: this,
      );

  Widget get expanded => Expanded(child: this);
  Widget get flexible => Flexible(child: this);
}
