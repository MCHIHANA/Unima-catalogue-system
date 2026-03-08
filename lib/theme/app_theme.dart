import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryNavy = Color(0xFF1A1F71);
  static const Color accentGold = Color(0xFFC69C2B);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textGrey = Color(0xFF636E72);

  static const Color sidebarBackground = Color(0xFFF1F3F9);
  static const Color goldBorder = Color(0xFFD4AF37);
  static const Color cardShadow = Color(0x0A000000);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryNavy,
    scaffoldBackgroundColor: surfaceWhite,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryNavy,
      primary: primaryNavy,
      secondary: accentGold,
      surface: surfaceWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceWhite,
      foregroundColor: textDark,
      elevation: 0,
      iconTheme: IconThemeData(color: textDark),
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color: textDark,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      headlineMedium: TextStyle(
        color: textDark,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      titleLarge: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(
        color: textDark,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textGrey,
        fontSize: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryNavy,
        foregroundColor: surfaceWhite,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryNavy, width: 2),
      ),
    ),
  );
}
