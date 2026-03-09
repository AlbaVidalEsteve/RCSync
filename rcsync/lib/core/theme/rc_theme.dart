import 'package:flutter/material.dart';
import 'rc_colors.dart'; // Asegúrate de importar tu clase de colores

final rcTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // Colores principales
  primaryColor: RCColors.orange,
  scaffoldBackgroundColor: RCColors.background,

  // Esquema de colores (Esencial para que widgets como botones o inputs hereden los colores)
  colorScheme: const ColorScheme.dark(
    primary: RCColors.orange,
    secondary: RCColors.darkBlue,
    surface: RCColors.cardDark,
    onPrimary: RCColors.white,
  ),

  // Tipografía: Usando RCColors.white
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: RCColors.white,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    bodyMedium: TextStyle(
      color: RCColors.white,
      fontSize: 16,
    ),
  ),

  // Cards: Usando RCColors.cardDark
  cardTheme: CardThemeData(
    color: RCColors.cardDark,
    margin: const EdgeInsets.symmetric(vertical: RCSpacing.sm),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
  ),

  // También puedes definir el estilo de los AppBars de una vez
  appBarTheme: const AppBarTheme(
    backgroundColor: RCColors.background,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: RCColors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
);
