import 'package:apsaratalent_mobile/core/enums/theme_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which theme the app is showing.
///
/// Defaults to [EThemeModeType.system]. The palette is contrast-solved in both
/// themes, so following the OS costs nothing and is what a reader expects.
class ThemeModeNotifier extends StateNotifier<EThemeModeType> {
  ThemeModeNotifier() : super(EThemeModeType.system);

  void set(EThemeModeType mode) => state = mode;
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, EThemeModeType>((ref) {
  return ThemeModeNotifier();
});

extension EThemeModeTypeX on EThemeModeType {
  ThemeMode get themeMode => switch (this) {
        EThemeModeType.light => ThemeMode.light,
        EThemeModeType.dark => ThemeMode.dark,
        EThemeModeType.system => ThemeMode.system,
      };
}
