import 'package:apsaratalent_mobile/core/themes/shadcn_colors.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class ShadCnFlexScheme {
  ShadCnFlexScheme._();

  static const FlexSchemeColor lightSchema = FlexSchemeColor(
    primary: ShadCnColors.lightPrimary,
    primaryContainer: ShadCnColors.lightMuted,
    secondary: ShadCnColors.lightSecondary,
    secondaryContainer: ShadCnColors.lightAccent,
    tertiary: ShadCnColors.chart1,
    tertiaryContainer: ShadCnColors.lightMuted,
    appBarColor: ShadCnColors.lightCard,
    error: ShadCnColors.lightDestructive,
    errorContainer: ShadCnColors.lightMuted,
  );

  static const FlexSchemeColor darkScheme = FlexSchemeColor(
    primary: ShadCnColors.darkPrimary,
    primaryContainer: ShadCnColors.darkMuted,
    secondary: ShadCnColors.darkSecondary,
    secondaryContainer: ShadCnColors.darkAccent,
    tertiary: ShadCnColors.chart1,
    tertiaryContainer: ShadCnColors.darkMuted,
    appBarColor: ShadCnColors.darkCard,
    error: ShadCnColors.darkDestructive,
    errorContainer: ShadCnColors.darkMuted,
  );
}
