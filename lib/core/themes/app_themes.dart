import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'shadcn_flex_scheme.dart';
import 'shadcn_colors.dart';
import 'app_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return FlexThemeData.light(
      colors: ShadCnFlexScheme.lightSchema,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 0, // No blending to keep exact colors
      appBarOpacity: 1.0,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 0,
        blendOnColors: false,
        useM2StyleDividerInM3: false,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,

        // Button styling (shadcn-like)
        elevatedButtonRadius: 8.0, // 0.5rem = 8px
        elevatedButtonElevation: 0,
        elevatedButtonSchemeColor: SchemeColor.primary,

        filledButtonRadius: 8.0,
        filledButtonSchemeColor: SchemeColor.primary,

        outlinedButtonRadius: 8.0,
        outlinedButtonBorderWidth: 1.0,
        outlinedButtonSchemeColor: SchemeColor.primary,

        textButtonRadius: 8.0,

        // Card styling
        cardRadius: 8.0,
        cardElevation: 0,

        // Input field styling
        inputDecoratorRadius: 8.0,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorBorderSchemeColor: SchemeColor.outline,
        inputDecoratorFocusedBorderWidth: 1.0,
        inputDecoratorBorderWidth: 1.0,

        // App Bar
        appBarBackgroundSchemeColor: SchemeColor.surface,
        appBarForegroundSchemeColor: SchemeColor.onSurface,
        appBarCenterTitle: false,

        // FAB
        fabRadius: 8.0,
        fabUseShape: true,
        fabSchemeColor: SchemeColor.primary,

        // Navigation Bar
        bottomNavigationBarElevation: 0,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,

        // Dialog
        dialogRadius: 8.0,
        dialogElevation: 0,

        // Bottom Sheet
        bottomSheetRadius: 8.0,
        bottomSheetElevation: 0,

        // Chip
        chipRadius: 8.0,
        chipBlendColors: false,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    ).copyWith(
      // Override specific colors to match Shadcn exactly
      scaffoldBackgroundColor: ShadCnColors.lightBackground,
      colorScheme: FlexColorScheme.light(
        colors: ShadCnFlexScheme.lightSchema,
        useMaterial3: true,
      ).toScheme.copyWith(
            surface: ShadCnColors.lightCard,
            onSurface: ShadCnColors.lightCardForeground,
            outline: ShadCnColors.lightBorder,
            outlineVariant: ShadCnColors.lightInput,
          ),
      // Global font theme
      textTheme: TextTheme(
        headlineLarge:
            AppFonts.headingLarge.copyWith(color: ShadCnColors.lightForeground),
        headlineMedium: AppFonts.headingMedium
            .copyWith(color: ShadCnColors.lightForeground),
        headlineSmall:
            AppFonts.headingSmall.copyWith(color: ShadCnColors.lightForeground),
        titleLarge:
            AppFonts.titleLarge.copyWith(color: ShadCnColors.lightForeground),
        titleMedium:
            AppFonts.titleMedium.copyWith(color: ShadCnColors.lightForeground),
        titleSmall:
            AppFonts.titleSmall.copyWith(color: ShadCnColors.lightForeground),
        bodyLarge:
            AppFonts.bodyLarge.copyWith(color: ShadCnColors.lightForeground),
        bodyMedium:
            AppFonts.bodyMedium.copyWith(color: ShadCnColors.lightForeground),
        bodySmall:
            AppFonts.bodySmall.copyWith(color: ShadCnColors.lightForeground),
        labelLarge:
            AppFonts.labelLarge.copyWith(color: ShadCnColors.lightForeground),
        labelMedium:
            AppFonts.labelMedium.copyWith(color: ShadCnColors.lightForeground),
        labelSmall:
            AppFonts.labelSmall.copyWith(color: ShadCnColors.lightForeground),
      ),
    );
  }

  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      colors: ShadCnFlexScheme.darkScheme,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 0, // No blending to keep exact colors
      appBarOpacity: 1.0,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 0,
        blendOnColors: false,
        useM2StyleDividerInM3: false,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,

        // Same styling as light theme
        elevatedButtonRadius: 8.0,
        elevatedButtonElevation: 0,
        elevatedButtonSchemeColor: SchemeColor.primary,

        filledButtonRadius: 8.0,
        filledButtonSchemeColor: SchemeColor.primary,

        outlinedButtonRadius: 8.0,
        outlinedButtonBorderWidth: 1.0,
        outlinedButtonSchemeColor: SchemeColor.primary,

        textButtonRadius: 8.0,

        cardRadius: 8.0,
        cardElevation: 0,

        inputDecoratorRadius: 8.0,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorBorderSchemeColor: SchemeColor.outline,
        inputDecoratorFocusedBorderWidth: 1.0,
        inputDecoratorBorderWidth: 1.0,

        appBarBackgroundSchemeColor: SchemeColor.surface,
        appBarForegroundSchemeColor: SchemeColor.onSurface,
        appBarCenterTitle: false,

        fabRadius: 8.0,
        fabUseShape: true,
        fabSchemeColor: SchemeColor.primary,

        bottomNavigationBarElevation: 0,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,

        dialogRadius: 8.0,
        dialogElevation: 0,

        bottomSheetRadius: 8.0,
        bottomSheetElevation: 0,

        chipRadius: 8.0,
        chipBlendColors: false,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    ).copyWith(
      // Override specific colors to match Shadcn exactly
      scaffoldBackgroundColor: ShadCnColors.darkBackground,
      colorScheme: FlexColorScheme.dark(
        colors: ShadCnFlexScheme.darkScheme,
        useMaterial3: true,
      ).toScheme.copyWith(
            surface: ShadCnColors.darkCard,
            onSurface: ShadCnColors.darkCardForeground,
            outline: ShadCnColors.darkBorder,
            outlineVariant: ShadCnColors.darkInput,
          ),
      // Global font theme
      textTheme: TextTheme(
        headlineLarge:
            AppFonts.headingLarge.copyWith(color: ShadCnColors.darkForeground),
        headlineMedium:
            AppFonts.headingMedium.copyWith(color: ShadCnColors.darkForeground),
        headlineSmall:
            AppFonts.headingSmall.copyWith(color: ShadCnColors.darkForeground),
        titleLarge:
            AppFonts.titleLarge.copyWith(color: ShadCnColors.darkForeground),
        titleMedium:
            AppFonts.titleMedium.copyWith(color: ShadCnColors.darkForeground),
        titleSmall:
            AppFonts.titleSmall.copyWith(color: ShadCnColors.darkForeground),
        bodyLarge:
            AppFonts.bodyLarge.copyWith(color: ShadCnColors.darkForeground),
        bodyMedium:
            AppFonts.bodyMedium.copyWith(color: ShadCnColors.darkForeground),
        bodySmall:
            AppFonts.bodySmall.copyWith(color: ShadCnColors.darkForeground),
        labelLarge:
            AppFonts.labelLarge.copyWith(color: ShadCnColors.darkForeground),
        labelMedium:
            AppFonts.labelMedium.copyWith(color: ShadCnColors.darkForeground),
        labelSmall:
            AppFonts.labelSmall.copyWith(color: ShadCnColors.darkForeground),
      ),
    );
  }
}
