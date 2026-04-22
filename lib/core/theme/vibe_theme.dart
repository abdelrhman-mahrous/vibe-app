import 'package:flutter/material.dart';

import '../constants/app_constant.dart';

class VibeColors {
  VibeColors._();

  // Core Background
  static const background = Color(0xFF0A0A1A);
  static const surface = Color(0xFF12122A);
  static const surfaceVariant = Color(0xFF1A1A35);
  static const cardBg = Color(0xFF16163A);

  // Gradients
  static const primaryPurple = Color(0xFF7B2FBE);
  static const deepPurple = Color(0xFF4A1080);
  static const accentViolet = Color(0xFF9D4EDD);
  static const glowPurple = Color(0xFFBB86FC);
  static const neonPurple = Color(0xFFCB6CE6);
  static const softBlue = Color(0xFF3A2D8F);
  static const midnightBlue = Color(0xFF1E1B4B);

  // Text
  static const textPrimary = Color(0xFFEEEEFF);
  static const textSecondary = Color(0xFFAAAAAF);
  static const textMuted = Color(0xFF666680);
  static const textAccent = Color(0xFFD4AAFF);

  // Glass
  static const glassWhite = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
  static const glassBorderLight = Color(0x1AFFFFFF);
  static const glassHighlight = Color(0x0DFFFFFF);

  // Accent
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFFF6B6B);
  static const info = Color(0xFF60A5FA);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, deepPurple],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0D2B), Color(0xFF070714), Color(0xFF0A0A1A)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1B5E), Color(0xFF12122A)],
  );

  static const LinearGradient glowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B2FBE), Color(0xFF4A1080), Color(0xFF9D4EDD)],
  );
}

class VibeTypography {
  VibeTypography._();
  static const fontFamily = "IBM";

  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: VibeColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: VibeColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: VibeColors.textPrimary,
    height: 1.4,
  );

  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: VibeColors.textPrimary,
    height: 1.4,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: VibeColors.textSecondary,
    height: 1.6,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: VibeColors.textSecondary,
    height: 1.5,
  );

  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: VibeColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: VibeColors.textSecondary,
    letterSpacing: 0.3,
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: VibeColors.textMuted,
    letterSpacing: 0.5,
  );
}

class VibeTheme {
  VibeTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: VibeTypography.fontFamily,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: VibeColors.background,
      colorScheme: const ColorScheme.dark(
        primary: VibeColors.primaryPurple,
        secondary: VibeColors.accentViolet,
        surface: VibeColors.surface,
        onPrimary: VibeColors.textPrimary,
        onSecondary: VibeColors.textPrimary,
        onSurface: VibeColors.textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: VibeTypography.displayLarge,
        displayMedium: VibeTypography.displayMedium,
        headlineLarge: VibeTypography.headlineLarge,
        headlineMedium: VibeTypography.headlineMedium,
        bodyLarge: VibeTypography.bodyLarge,
        bodyMedium: VibeTypography.bodyMedium,
        labelLarge: VibeTypography.labelLarge,
        labelMedium: VibeTypography.labelMedium,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

// Spacing constants
class VibeSpacing {
  VibeSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

// Border radius constants
class VibeRadius {
  VibeRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 100;
}
