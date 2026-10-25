import 'package:flutter/material.dart';

class RouteDuckTheme {
  // === Ortak Renkler ===
  static const Color peachAmber = Color(0xFFEDA45F);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color deepForest = Color(0xFF0D532B);
  static const Color duckOrange = Color(0xFFE65C00);

  // === Koyu Mod Renkleri (Glass & Emerald Obsidian) ===
  static const Color darkScaffold = Color(0xFF120B07);
  static const Color darkCard = Color(0xFF1E140E);
  static const Color darkBorder = Color(0xFF2E1E15);
  static const Color darkActiveTaskCard = Color(0xFF162319);
  static const Color darkTextPrimary = Color(0xFFFAF4EF);
  static const Color darkTextSecondary = Color(0xFFA38977);
  static const Color darkMuted = Color(0xFF6E5646);

  // === Aydınlık Mod Renkleri (Warm Linen & Emerald) ===
  static const Color lightScaffold = Color(0xFFF6F3EE);
  static const Color lightCard = Color(0xFFFDFAF7);
  static const Color lightBorder = Color(0xFFE5DDD3);
  static const Color lightActiveTaskCard = Color(0xFFEDF6F0);
  static const Color lightTextPrimary = Color(0xFF1F1610);
  static const Color lightTextSecondary = Color(0xFF6E5E52);
  static const Color lightMuted = Color(0xFF9C8B7E);

  // === KOYU TEMA (DARK THEME) ===
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkScaffold,
      primaryColor: peachAmber,
      colorScheme: const ColorScheme.dark(
        primary: peachAmber,
        secondary: emeraldGreen,
        surface: darkCard,
        onSurface: darkTextPrimary,
        outline: darkBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkScaffold,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: peachAmber,
          foregroundColor: const Color(0xFF120A05),
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A110B),
        hintStyle: const TextStyle(color: darkMuted, fontSize: 14),
        labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: peachAmber, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
    );
  }

  // === AYDINLIK TEMA (LIGHT THEME - WARM LINEN) ===
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightScaffold,
      primaryColor: deepForest,
      colorScheme: const ColorScheme.light(
        primary: deepForest,
        secondary: Color(0xFFD97706),
        surface: lightCard,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightScaffold,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepForest,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: lightMuted, fontSize: 14),
        labelStyle: const TextStyle(color: lightTextSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: deepForest, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
      ),
    );
  }
}
