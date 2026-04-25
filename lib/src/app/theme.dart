import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  final TextTheme baseText = ThemeData.dark().textTheme;
  final TextTheme textTheme = GoogleFonts.interTextTheme(baseText).copyWith(
    displayLarge: GoogleFonts.playfairDisplay(
      color: AetherPalette.textPrimary,
      fontSize: 72,
      fontWeight: FontWeight.w300,
      letterSpacing: -1,
      height: 0.95,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      color: AetherPalette.textPrimary,
      fontSize: 58,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.playfairDisplay(
      color: AetherPalette.textPrimary,
      fontSize: 50,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      color: AetherPalette.textPrimary,
      fontSize: 42,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: GoogleFonts.playfairDisplay(
      color: AetherPalette.textPrimary,
      fontSize: 30,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.inter(
      color: AetherPalette.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    titleMedium: GoogleFonts.inter(
      color: AetherPalette.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    bodyLarge: GoogleFonts.inter(
      color: AetherPalette.textPrimary,
      fontSize: 15,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.inter(
      color: AetherPalette.textMuted,
      fontSize: 14,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.inter(
      color: AetherPalette.textDim,
      fontSize: 12,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.inter(
      color: AetherPalette.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );

  final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
    primary: AetherPalette.accent,
    onPrimary: AetherPalette.background,
    secondary: AetherPalette.gold,
    surface: AetherPalette.panelSoft,
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
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AetherPalette.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.playfairDisplay(
        color: AetherPalette.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w400,
      ),
    ),
    cardTheme: CardThemeData(
      color: AetherPalette.backgroundElevated.withValues(alpha: 0.98),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AetherPalette.panelBorderSolid.withValues(alpha: 0.9),
        ),
      ),
    ),
    dividerColor: AetherPalette.panelBorderSolid.withValues(alpha: 0.85),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: textTheme.bodyMedium,
      hintStyle: textTheme.bodyMedium?.copyWith(color: AetherPalette.textDim),
      filled: true,
      fillColor: AetherPalette.backgroundElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AetherPalette.panelBorderSolid.withValues(alpha: 0.95),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AetherPalette.panelBorderSolid.withValues(alpha: 0.95),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AetherPalette.accent, width: 1.2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AetherPalette.accent,
        foregroundColor: AetherPalette.background,
        disabledBackgroundColor: AetherPalette.panelSoft,
        disabledForegroundColor: AetherPalette.textDim,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        overlayColor: Colors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AetherPalette.textPrimary,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        side: BorderSide(
          color: AetherPalette.panelBorderSolid.withValues(alpha: 0.9),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        overlayColor: Colors.transparent,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AetherPalette.accentHover,
        textStyle: textTheme.labelLarge,
        overlayColor: Colors.transparent,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll<Color>(
          AetherPalette.textMuted,
        ),
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return AetherPalette.panelSoft;
            }
            return null;
          },
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      backgroundColor: AetherPalette.backgroundElevated,
      selectedColor: AetherPalette.accentSoft,
      secondarySelectedColor: AetherPalette.accentSoft,
      side: BorderSide(
        color: AetherPalette.panelBorderSolid.withValues(alpha: 0.85),
      ),
      labelStyle: textTheme.bodyMedium!,
      secondaryLabelStyle: textTheme.bodyLarge!,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? AetherPalette.accentSoft
              : AetherPalette.backgroundElevated,
        ),
        foregroundColor: const WidgetStatePropertyAll<Color>(
          AetherPalette.textPrimary,
        ),
        side: WidgetStatePropertyAll<BorderSide>(
          BorderSide(
            color: AetherPalette.panelBorderSolid.withValues(alpha: 0.85),
          ),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll<Color>(AetherPalette.textPrimary),
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => states.contains(WidgetState.selected)
            ? AetherPalette.accent.withValues(alpha: 0.55)
            : AetherPalette.panelBorderSolid,
      ),
    ),
    iconTheme: const IconThemeData(color: AetherPalette.textMuted),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AetherPalette.accent,
    ),
  );
}
