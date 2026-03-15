import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const Color sand = Color(0xFFF3EAD8);
  const Color ember = Color(0xFFB35C44);
  const Color forest = Color(0xFF1F3B36);
  const Color brass = Color(0xFFC99B4D);

  final ColorScheme colorScheme =
      ColorScheme.fromSeed(
        seedColor: ember,
        brightness: Brightness.light,
      ).copyWith(
        primary: ember,
        secondary: brass,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: forest,
        onSurface: forest,
      );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: sand,
    appBarTheme: const AppBarTheme(
      backgroundColor: forest,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDACDB8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDACDB8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: ember, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: forest,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: const ChipThemeData(
      shape: StadiumBorder(),
      backgroundColor: Color(0xFFFFF6E7),
      selectedColor: Color(0xFFFFE1B0),
      secondarySelectedColor: Color(0xFFFFE1B0),
      side: BorderSide(color: Color(0xFFE0C89C)),
      labelStyle: TextStyle(color: forest),
      secondaryLabelStyle: TextStyle(color: forest),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
  );
}
