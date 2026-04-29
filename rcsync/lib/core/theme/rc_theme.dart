import 'package:flutter/material.dart';
import 'rc_colors.dart';

class RCTheme {
  // Tipografia base
  static const _textTheme = TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
    displayMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(fontSize: 14),
  );

  static AppBarTheme _appBarTheme(Color backgroundColor, Color foregroundColor) => AppBarTheme(
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: foregroundColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );

  static CardThemeData _cardTheme(Color color) => CardThemeData(
    color: color,
    margin: const EdgeInsets.symmetric(vertical: RCSpacing.sm, horizontal: RCSpacing.md),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: RCColors.orange,
    scaffoldBackgroundColor: RCColors.bgDark,
    colorScheme: const ColorScheme.dark(
      primary: RCColors.orange,
      secondary: RCColors.darkBlue,
      surface: RCColors.surfaceDark,
      onPrimary: Colors.white,
      onSurface: RCColors.textPrimaryDark,
    ),
    textTheme: _textTheme.apply(
      bodyColor: RCColors.textPrimaryDark,
      displayColor: RCColors.textPrimaryDark,
    ),
    appBarTheme: _appBarTheme(RCColors.bgDark, Colors.white),
    cardTheme: _cardTheme(RCColors.cardDark),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: RCColors.orange,
    scaffoldBackgroundColor: RCColors.bgLight,
    colorScheme: const ColorScheme.light(
      primary: RCColors.orange,
      secondary: RCColors.darkBlue,
      surface: RCColors.surfaceLight,
      onPrimary: Colors.white,
      onSurface: RCColors.textPrimaryLight,
    ),
    textTheme: _textTheme.apply(
      bodyColor: RCColors.textPrimaryLight,
      displayColor: RCColors.textPrimaryLight,
    ),
    appBarTheme: _appBarTheme(RCColors.bgLight, RCColors.textPrimaryLight),
    cardTheme: _cardTheme(RCColors.cardLight),
  );
}
