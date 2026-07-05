import 'package:flutter/material.dart';

extension TextThemeExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Headline styles
  TextStyle get headlineLarge => textTheme.headlineLarge!;
  TextStyle get headlineMedium => textTheme.headlineMedium!;
  TextStyle get headlineSmall => textTheme.headlineSmall!;

  // Title styles
  TextStyle get titleLarge => textTheme.titleLarge!;
  TextStyle get titleMedium => textTheme.titleMedium!;
  TextStyle get titleSmall => textTheme.titleSmall!;

  // Body styles
  TextStyle get bodyLarge => textTheme.bodyLarge!;
  TextStyle get bodyMedium => textTheme.bodyMedium!;
  TextStyle get bodySmall => textTheme.bodySmall!;

  // Label styles
  TextStyle get labelLarge => textTheme.labelLarge!;
  TextStyle get labelMedium => textTheme.labelMedium!;
  TextStyle get labelSmall => textTheme.labelSmall!;
}

extension TextStyleModifiers on TextStyle {
  // Color modifiers
  TextStyle get primary => copyWith(color: const Color(0xFF171717));
  TextStyle get secondary => copyWith(color: const Color(0xFF737373));
  TextStyle get muted => copyWith(color: const Color(0xFF737373));
  TextStyle get destructive => copyWith(color: const Color(0xFFEF4444));

  // Weight modifiers
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  // Size modifiers
  TextStyle get xs => copyWith(fontSize: 12);
  TextStyle get sm => copyWith(fontSize: 14);
  TextStyle get base => copyWith(fontSize: 16);
  TextStyle get lg => copyWith(fontSize: 18);
  TextStyle get xl => copyWith(fontSize: 20);
  TextStyle get xl2 => copyWith(fontSize: 24);
  TextStyle get xl3 => copyWith(fontSize: 30);
  TextStyle get xl4 => copyWith(fontSize: 36);

  // Other modifiers
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  // Letter spacing
  TextStyle get tight => copyWith(letterSpacing: -0.5);
  TextStyle get normal => copyWith(letterSpacing: 0);
  TextStyle get wide => copyWith(letterSpacing: 0.5);
  TextStyle get wider => copyWith(letterSpacing: 1.0);

  // Line height
  TextStyle get leadingTight => copyWith(height: 1.2);
  TextStyle get leadingNormal => copyWith(height: 1.5);
  TextStyle get leadingRelaxed => copyWith(height: 1.8);
}
