import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryNavy = Color(0xFF1A1F71);
  static const Color accentGold = Color(0xFFC69C2B);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceSoft = Color(0xFFF4F6FB);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textGrey = Color(0xFF636E72);

  static const Color sidebarBackground = Color(0xFFF1F3F9);
  static const Color goldBorder = Color(0xFFD4AF37);
  static const Color cardShadow = Color(0x0A000000);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryNavy,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryNavy,
      primary: primaryNavy,
      secondary: accentGold,
      surface: surfaceWhite,
      surfaceContainerHighest: surfaceSoft,
      tertiary: accentBlue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceWhite,
      foregroundColor: textDark,
      elevation: 0,
      iconTheme: IconThemeData(color: textDark),
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w900,
        fontSize: 18,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceWhite,
      surfaceTintColor: surfaceWhite,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w900
              : FontWeight.w700,
          color: states.contains(WidgetState.selected) ? primaryNavy : textGrey,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? primaryNavy : textGrey,
        ),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: surfaceWhite,
      surfaceTintColor: surfaceWhite,
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
      bodyLarge: TextStyle(color: textDark, fontSize: 16),
      bodyMedium: TextStyle(color: textGrey, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryNavy,
        foregroundColor: surfaceWhite,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        elevation: 0,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryNavy,
        foregroundColor: surfaceWhite,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryNavy,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        side: BorderSide(color: primaryNavy.withValues(alpha: 0.18)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryNavy,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryNavy, width: 2),
      ),
    ),
  );
}
