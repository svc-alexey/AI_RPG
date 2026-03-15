import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  final TextTheme baseText = ThemeData.dark().textTheme;
  final TextTheme textTheme = GoogleFonts.manropeTextTheme(baseText).copyWith(
    displayLarge: GoogleFonts.cormorantGaramond(
      color: AetherPalette.textPrimary,
      fontSize: 72,
      fontWeight: FontWeight.w500,
      letterSpacing: 10,
    ),
    displayMedium: GoogleFonts.cormorantGaramond(
      color: AetherPalette.textPrimary,
      fontSize: 58,
      fontWeight: FontWeight.w500,
      letterSpacing: 5,
    ),
    headlineLarge: GoogleFonts.cormorantGaramond(
      color: AetherPalette.textPrimary,
      fontSize: 50,
      fontWeight: FontWeight.w500,
    ),
    headlineMedium: GoogleFonts.cormorantGaramond(
      color: AetherPalette.textPrimary,
      fontSize: 42,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: GoogleFonts.cormorantGaramond(
      color: AetherPalette.textPrimary,
      fontSize: 30,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.manrope(
      color: AetherPalette.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
    titleMedium: GoogleFonts.manrope(
      color: AetherPalette.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    bodyLarge: GoogleFonts.manrope(
      color: AetherPalette.textPrimary,
      fontSize: 15,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.manrope(
      color: AetherPalette.textMuted,
      fontSize: 14,
      height: 1.5,
    ),
    labelLarge: GoogleFonts.manrope(
      color: AetherPalette.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    ),
  );

  final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
    primary: AetherPalette.accent,
    secondary: AetherPalette.gold,
    surface: AetherPalette.panel,
    onSurface: AetherPalette.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    splashFactory: NoSplash.splashFactory,
    hoverColor: Colors.transparent,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AetherPalette.background,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AetherPalette.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.cormorantGaramond(
        color: AetherPalette.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
    ),
    cardTheme: CardThemeData(
      color: AetherPalette.panel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: AetherPalette.panelBorder.withValues(alpha: 0.7),
        ),
      ),
    ),
    dividerColor: AetherPalette.panelBorder.withValues(alpha: 0.4),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: textTheme.bodyMedium,
      hintStyle: textTheme.bodyMedium,
      filled: true,
      fillColor: AetherPalette.panelSoft.withValues(alpha: 0.8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AetherPalette.panelBorder.withValues(alpha: 0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AetherPalette.panelBorder.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AetherPalette.accent, width: 1.2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AetherPalette.accentSoft.withValues(alpha: 0.45),
        foregroundColor: AetherPalette.textPrimary,
        minimumSize: const Size(0, 58),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: AetherPalette.panelBorder.withValues(alpha: 0.7),
          ),
        ),
        overlayColor: Colors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AetherPalette.textPrimary,
        minimumSize: const Size(0, 58),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        side: BorderSide(
          color: AetherPalette.panelBorder.withValues(alpha: 0.65),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        overlayColor: Colors.transparent,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AetherPalette.textMuted,
        textStyle: textTheme.labelLarge,
        overlayColor: Colors.transparent,
      ),
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll<Color>(
          AetherPalette.textMuted,
        ),
        overlayColor: WidgetStatePropertyAll<Color>(Colors.transparent),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: AetherPalette.panelSoft.withValues(alpha: 0.75),
      selectedColor: AetherPalette.accentSoft.withValues(alpha: 0.34),
      secondarySelectedColor: AetherPalette.accentSoft.withValues(alpha: 0.34),
      side: BorderSide(
        color: AetherPalette.panelBorder.withValues(alpha: 0.55),
      ),
      labelStyle: textTheme.bodyMedium!,
      secondaryLabelStyle: textTheme.bodyLarge!,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? AetherPalette.accentSoft.withValues(alpha: 0.42)
              : AetherPalette.panelSoft.withValues(alpha: 0.7),
        ),
        foregroundColor: const WidgetStatePropertyAll<Color>(
          AetherPalette.textPrimary,
        ),
        side: WidgetStatePropertyAll<BorderSide>(
          BorderSide(
            color: AetherPalette.panelBorder.withValues(alpha: 0.72),
          ),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll<Color>(AetherPalette.textPrimary),
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => states.contains(WidgetState.selected)
            ? AetherPalette.accentSoft
            : AetherPalette.panelBorder,
      ),
    ),
    iconTheme: const IconThemeData(color: AetherPalette.textMuted),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AetherPalette.accent,
    ),
  );
}
