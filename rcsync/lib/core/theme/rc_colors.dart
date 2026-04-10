import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RCColors {
  // --- BRAND COLORS (Constants) ---
  static const orange = Color(0xFFF24E02);
  static const darkBlue = Color(0xFF02255A);
  static const whiteRc = Color(0xFFFFFFFF);
  static const blackRc = Color(0xFF000000);

  // --- RAW PALETTE ---
  static const bgDark = Color(0xFF090F18);
  static const cardDark = Color(0xFF272E37);
  static const surfaceDark = Color(0xFF1C222B);
  static const textPrimaryDark = Color(0xFFEAEAEB);
  static const textSecondaryDark = Color(0xFFB0B0B0);

  static const bgLight = Color(0xFFEAEAEB);
  static const cardLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF5F5F7);
  static const textPrimaryLight = Color(0xFF090F18);
  static const textSecondaryLight = Color(0xFF474F59);

  // --- SEMANTIC GETTERS ---
  // Usamos Get.isDarkMode directamente para evitar inconsistencias con Get.theme
  // que a veces no se actualiza instantáneamente en todos los contextos.
  
  static Color get background => Get.isDarkMode ? bgDark : bgLight;
  static Color get card => Get.isDarkMode ? cardDark : cardLight;
  static Color get surface => Get.isDarkMode ? surfaceDark : surfaceLight;
  static Color get textPrimary => Get.isDarkMode ? textPrimaryDark : textPrimaryLight;
  static Color get textSecondary => Get.isDarkMode ? textSecondaryDark : textSecondaryLight;
  
  // Adaptive utility colors
  static Color get white => Get.isDarkMode ? textPrimaryDark : whiteRc;
  static Color get black => Get.isDarkMode ? blackRc : textPrimaryLight;
  static Color get iconPrimary => Get.isDarkMode ? textPrimaryDark : textSecondaryLight;
  static Color get iconSecondary => Get.isDarkMode ? textSecondaryDark : textSecondaryLight.withOpacity(0.7);
  static Color get divider => Get.isDarkMode ? Colors.white10 : Colors.black12;
  
  // Static Utility Colors (Always the same)
  static const error = Color(0xFFD32F2F);
  static const success = Color(0xFF388E3C);
  static const info = Color(0xFF1976D2);
  static const gold = Color(0xFFFFD700);
  static const silver = Color(0xFFC0C0C0);
  static const bronze = Color(0xFFCD7F32);
}

class RCSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
}
