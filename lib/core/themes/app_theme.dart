import 'package:flutter/material.dart';

import 'package:apsaratalent_mobile/core/themes/app_elevation.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/themes/app_tokens.dart';
import 'package:apsaratalent_mobile/core/themes/app_typography.dart';

/// Builds [ThemeData] from [AppTokens].
///
/// This is assembled by hand rather than through a theme-generator package on
/// purpose. Generators blend and derive their own surface ramps, which is
/// exactly what must not happen here: the palette is contrast-solved upstream
/// in the web app's `globals.css`, and a container tint computed on top of a
/// token silently moves it off the value that cleared WCAG.
///
/// Material's own elevation is switched off throughout. Depth in this UI is the
/// hard offset shadow in [AppElevation], drawn by the widget; a Material
/// elevation on top of it would add a second, soft, differently-angled shadow.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(AppTokens.light, Brightness.light);
  static ThemeData dark() => _build(AppTokens.dark, Brightness.dark);

  static ThemeData _build(AppTokens t, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: t.primary,
      onPrimary: t.primaryForeground,
      secondary: t.secondary,
      onSecondary: t.secondaryForeground,
      error: t.destructive,
      onError: t.destructiveForeground,
      surface: t.card,
      onSurface: t.cardForeground,
      // Material's "container" roles are mapped onto the tokens that already
      // mean the same thing rather than being left to derive themselves.
      primaryContainer: t.accent,
      onPrimaryContainer: t.accentForeground,
      secondaryContainer: t.muted,
      onSecondaryContainer: t.mutedForeground,
      surfaceContainerHighest: t.muted,
      onSurfaceVariant: t.mutedForeground,
      outline: t.border,
      outlineVariant: t.input,
      scrim: t.scrim,
      shadow: t.foreground,
      inverseSurface: t.foreground,
      onInverseSurface: t.background,
    );

    // Square, full stop. Declared once so no component theme below can quietly
    // reintroduce a corner.
    const square = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppShape.radius)),
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.h1,
      headlineLarge: AppTypography.h1,
      headlineMedium: AppTypography.h2,
      headlineSmall: AppTypography.h3,
      titleLarge: AppTypography.h4,
      titleMedium: AppTypography.label,
      titleSmall: AppTypography.muted,
      bodyLarge: AppTypography.p,
      bodyMedium: AppTypography.small,
      bodySmall: AppTypography.tiny,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.tag,
      labelSmall: AppTypography.statLabel,
    ).apply(
      bodyColor: t.foreground,
      displayColor: t.foreground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: t.background,
      canvasColor: t.background,
      dividerColor: t.border,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[
        t,
        AppElevation.of(t, isDark: isDark),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: t.background,
        foregroundColor: t.foreground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h4.copyWith(color: t.foreground),
      ),
      cardTheme: CardThemeData(
        color: t.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: square,
      ),
      dividerTheme: DividerThemeData(
        color: t.border,
        thickness: AppShape.hairline,
        space: AppShape.hairline,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: square,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: square,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.popover,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: square,
        textStyle: AppTypography.small.copyWith(color: t.popoverForeground),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.foreground,
        contentTextStyle: AppTypography.small.copyWith(color: t.background),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: square,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: t.foreground),
        textStyle: AppTypography.tiny.copyWith(color: t.background),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.background,
        // `border` is decorative; a control's boundary uses `input`, which is
        // deliberately darker so it holds the 3:1 of WCAG 1.4.11.
        border: _fieldBorder(t.input),
        enabledBorder: _fieldBorder(t.input),
        focusedBorder: _fieldBorder(t.ring),
        errorBorder: _fieldBorder(t.destructive),
        focusedErrorBorder: _fieldBorder(t.destructive),
        disabledBorder: _fieldBorder(t.border),
        hintStyle: AppTypography.small.copyWith(
          color: t.mutedForeground.withValues(alpha: 0.7),
        ),
        labelStyle: AppTypography.label.copyWith(color: t.mutedForeground),
        errorStyle: AppTypography.tiny.copyWith(color: t.destructive),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppShape.space3,
          vertical: AppShape.space3,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: square,
        side: BorderSide(color: t.input, width: AppShape.hairline),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? t.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(t.primaryForeground),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? t.primary
              : t.input,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? t.primaryForeground
              : t.background,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? t.primary
              : t.muted,
        ),
        trackOutlineColor: WidgetStatePropertyAll(t.input),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.primary,
        linearTrackColor: t.muted,
        circularTrackColor: t.muted,
      ),
      iconTheme: IconThemeData(color: t.foreground, size: 20),
      listTileTheme: ListTileThemeData(
        shape: square,
        iconColor: t.mutedForeground,
        textColor: t.foreground,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.muted,
        side: BorderSide(color: t.border, width: AppShape.hairline),
        shape: square,
        labelStyle: AppTypography.tag.copyWith(color: t.foreground),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: t.primary,
        unselectedLabelColor: t.mutedForeground,
        indicatorColor: t.primary,
        dividerColor: t.border,
        labelStyle: AppTypography.button,
        unselectedLabelStyle: AppTypography.button,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: t.primary,
        selectionColor: t.primary.withValues(alpha: 0.25),
        selectionHandleColor: t.primary,
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShape.radius),
        borderSide: BorderSide(color: color, width: AppShape.hairline),
      );
}
