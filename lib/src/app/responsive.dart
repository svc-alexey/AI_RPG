import 'package:flutter/material.dart';

enum AppBreakpoint { phoneSmall, phone, phoneLarge, tablet, desktop }

class AppResponsiveData {
  const AppResponsiveData._({required this.width, required this.breakpoint});

  factory AppResponsiveData.of(final BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return AppResponsiveData._(
      width: width,
      breakpoint: width < 360
          ? AppBreakpoint.phoneSmall
          : width < 390
          ? AppBreakpoint.phone
          : width < 600
          ? AppBreakpoint.phoneLarge
          : width < 1024
          ? AppBreakpoint.tablet
          : AppBreakpoint.desktop,
    );
  }

  final double width;
  final AppBreakpoint breakpoint;

  bool get isPhoneSmall => breakpoint == AppBreakpoint.phoneSmall;
  bool get isPhone => breakpoint == AppBreakpoint.phone;
  bool get isPhoneLarge => breakpoint == AppBreakpoint.phoneLarge;
  bool get isTablet => breakpoint == AppBreakpoint.tablet;
  bool get isDesktop => breakpoint == AppBreakpoint.desktop;
  bool get isCompact => isPhoneSmall || isPhone;
  bool get isMobile => isPhoneSmall || isPhone || isPhoneLarge;
  bool get isWide => isTablet || isDesktop;

  double get pagePadding => switch (breakpoint) {
    AppBreakpoint.phoneSmall => 12,
    AppBreakpoint.phone => 14,
    AppBreakpoint.phoneLarge => 16,
    AppBreakpoint.tablet => 20,
    AppBreakpoint.desktop => 24,
  };

  double get cardPadding => switch (breakpoint) {
    AppBreakpoint.phoneSmall => 14,
    AppBreakpoint.phone => 16,
    AppBreakpoint.phoneLarge => 18,
    AppBreakpoint.tablet => 20,
    AppBreakpoint.desktop => 24,
  };

  double get sectionSpacing => switch (breakpoint) {
    AppBreakpoint.phoneSmall => 10,
    AppBreakpoint.phone => 12,
    AppBreakpoint.phoneLarge => 14,
    AppBreakpoint.tablet => 16,
    AppBreakpoint.desktop => 16,
  };

  double get blockSpacing => switch (breakpoint) {
    AppBreakpoint.phoneSmall => 18,
    AppBreakpoint.phone => 20,
    AppBreakpoint.phoneLarge => 22,
    AppBreakpoint.tablet => 24,
    AppBreakpoint.desktop => 24,
  };

  double get cardRadius => switch (breakpoint) {
    AppBreakpoint.phoneSmall => 18,
    AppBreakpoint.phone => 20,
    AppBreakpoint.phoneLarge => 20,
    AppBreakpoint.tablet => 22,
    AppBreakpoint.desktop => 22,
  };

  double get inputVerticalPadding => switch (breakpoint) {
    AppBreakpoint.phoneSmall => 12,
    AppBreakpoint.phone => 13,
    AppBreakpoint.phoneLarge => 14,
    AppBreakpoint.tablet => 16,
    AppBreakpoint.desktop => 18,
  };

  double get buttonMinHeight => switch (breakpoint) {
    AppBreakpoint.phoneSmall => 46,
    AppBreakpoint.phone => 48,
    AppBreakpoint.phoneLarge => 50,
    AppBreakpoint.tablet => 54,
    AppBreakpoint.desktop => 58,
  };

  double get buttonVerticalPadding => switch (breakpoint) {
    AppBreakpoint.phoneSmall => 12,
    AppBreakpoint.phone => 13,
    AppBreakpoint.phoneLarge => 14,
    AppBreakpoint.tablet => 16,
    AppBreakpoint.desktop => 18,
  };

  double get chipVerticalPadding => switch (breakpoint) {
    AppBreakpoint.phoneSmall => 7,
    AppBreakpoint.phone => 8,
    AppBreakpoint.phoneLarge => 9,
    AppBreakpoint.tablet => 10,
    AppBreakpoint.desktop => 10,
  };

  double get segmentedVerticalPadding => switch (breakpoint) {
    AppBreakpoint.phoneSmall => 10,
    AppBreakpoint.phone => 11,
    AppBreakpoint.phoneLarge => 12,
    AppBreakpoint.tablet => 13,
    AppBreakpoint.desktop => 14,
  };

  double get sidebarWidth => switch (breakpoint) {
    AppBreakpoint.phoneSmall => width,
    AppBreakpoint.phone => width,
    AppBreakpoint.phoneLarge => width,
    AppBreakpoint.tablet => 280,
    AppBreakpoint.desktop => 320,
  };

  double get overlayMaxWidth => switch (breakpoint) {
    AppBreakpoint.phoneSmall => width * 0.72,
    AppBreakpoint.phone => width * 0.74,
    AppBreakpoint.phoneLarge => width * 0.76,
    AppBreakpoint.tablet => 220,
    AppBreakpoint.desktop => 240,
  };

  double get dialogMaxWidth => switch (breakpoint) {
    AppBreakpoint.phoneSmall => width,
    AppBreakpoint.phone => width,
    AppBreakpoint.phoneLarge => width,
    AppBreakpoint.tablet => 640,
    AppBreakpoint.desktop => 760,
  };

  double scaleFont(final double desktopSize) {
    if (isPhoneSmall) {
      return desktopSize * 0.76;
    }
    if (isPhone) {
      return desktopSize * 0.82;
    }
    if (isPhoneLarge) {
      return desktopSize * 0.88;
    }
    if (isTablet) {
      return desktopSize * 0.94;
    }
    return desktopSize;
  }

  double scaleLetterSpacing(final double desktopSpacing) {
    if (isPhoneSmall) {
      return desktopSpacing * 0.45;
    }
    if (isPhone) {
      return desktopSpacing * 0.55;
    }
    if (isPhoneLarge) {
      return desktopSpacing * 0.7;
    }
    if (isTablet) {
      return desktopSpacing * 0.85;
    }
    return desktopSpacing;
  }
}

extension AppResponsiveContext on BuildContext {
  AppResponsiveData get responsive => AppResponsiveData.of(this);
}

ThemeData adaptThemeForContext(
  final BuildContext context,
  final ThemeData baseTheme,
) {
  final AppResponsiveData responsive = context.responsive;
  final TextTheme baseText = baseTheme.textTheme;

  TextStyle? scaled(
    final TextStyle? style, {
    final double? fontSize,
    final double? letterSpacing,
  }) => style?.copyWith(
    fontSize: responsive.scaleFont(fontSize ?? style.fontSize ?? 14),
    letterSpacing: letterSpacing == null
        ? style.letterSpacing
        : responsive.scaleLetterSpacing(letterSpacing),
  );

  return baseTheme.copyWith(
    textTheme: baseText.copyWith(
      displayLarge: scaled(
        baseText.displayLarge,
        fontSize: 72,
        letterSpacing: 10,
      ),
      displayMedium: scaled(
        baseText.displayMedium,
        fontSize: 58,
        letterSpacing: 5,
      ),
      headlineLarge: scaled(baseText.headlineLarge, fontSize: 50),
      headlineMedium: scaled(baseText.headlineMedium, fontSize: 42),
      headlineSmall: scaled(baseText.headlineSmall, fontSize: 30),
      titleLarge: scaled(baseText.titleLarge, fontSize: 18, letterSpacing: 1.2),
      titleMedium: scaled(
        baseText.titleMedium,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
      bodyLarge: scaled(baseText.bodyLarge, fontSize: 15),
      bodyMedium: scaled(baseText.bodyMedium, fontSize: 14),
      labelLarge: scaled(baseText.labelLarge, fontSize: 14, letterSpacing: 0.8),
    ),
    appBarTheme: baseTheme.appBarTheme.copyWith(
      titleTextStyle: scaled(
        baseTheme.appBarTheme.titleTextStyle,
        fontSize: 28,
      ),
      toolbarHeight: responsive.isCompact ? 60 : null,
    ),
    cardTheme: baseTheme.cardTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.cardRadius + 2),
        side: BorderSide(color: const Color(0xFF3A2F49).withValues(alpha: 0.7)),
      ),
    ),
    inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
      contentPadding: EdgeInsets.symmetric(
        horizontal: responsive.isCompact ? 14 : 18,
        vertical: responsive.inputVerticalPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsive.isCompact ? 14 : 18),
        borderSide:
            baseTheme.inputDecorationTheme.border?.borderSide ??
            BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsive.isCompact ? 14 : 18),
        borderSide:
            baseTheme.inputDecorationTheme.enabledBorder?.borderSide ??
            BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsive.isCompact ? 14 : 18),
        borderSide:
            baseTheme.inputDecorationTheme.focusedBorder?.borderSide ??
            BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: baseTheme.filledButtonTheme.style?.copyWith(
        minimumSize: WidgetStatePropertyAll<Size>(
          Size(0, responsive.buttonMinHeight),
        ),
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            horizontal: responsive.isCompact ? 18 : 22,
            vertical: responsive.buttonVerticalPadding,
          ),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.isCompact ? 14 : 18),
            side: BorderSide(
              color: const Color(0xFF3A2F49).withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: baseTheme.outlinedButtonTheme.style?.copyWith(
        minimumSize: WidgetStatePropertyAll<Size>(
          Size(0, responsive.buttonMinHeight),
        ),
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            horizontal: responsive.isCompact ? 18 : 22,
            vertical: responsive.buttonVerticalPadding,
          ),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.isCompact ? 14 : 18),
          ),
        ),
      ),
    ),
    chipTheme: baseTheme.chipTheme.copyWith(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.isCompact ? 12 : 14,
        vertical: responsive.chipVerticalPadding,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: baseTheme.segmentedButtonTheme.style?.copyWith(
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            horizontal: responsive.isCompact ? 14 : 18,
            vertical: responsive.segmentedVerticalPadding,
          ),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.isCompact ? 14 : 16),
          ),
        ),
      ),
    ),
  );
}
