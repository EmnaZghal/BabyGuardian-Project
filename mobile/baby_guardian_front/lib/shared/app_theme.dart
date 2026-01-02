import 'package:flutter/material.dart';
import 'app_palette.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.oceanBlue,
      primary: AppPalette.oceanBlue,
      secondary: AppPalette.turquoise,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppPalette.bg,
    fontFamily: null, // mets ta police si besoin
  );
}
