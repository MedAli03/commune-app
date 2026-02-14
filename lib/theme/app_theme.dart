import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}

class AppRadii {
  static const BorderRadius sm = BorderRadius.all(Radius.circular(12));
  static const BorderRadius md = BorderRadius.all(Radius.circular(14));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(24));
}

class AppPalette {
  static const Color accentGreen = Color(0xFF5BE855);
  static const Color backgroundDark = Color(0xFF091326);
  static const Color surface = Color(0xFF111E2E);
  static const Color surfaceAlt = Color(0xFF17263A);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textMuted = Color(0xFFA0AEC0);
  static const Color outline = Color(0xFF2A3A4D);
  static const Color outlineSoft = Color(0xFF233448);
}

class AppTextStyles {
  static const TextStyle titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppPalette.textPrimary,
  );

  static const TextStyle subtitleGreen = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppPalette.accentGreen,
    height: 1.3,
  );

  static const TextStyle metaMuted = TextStyle(
    fontSize: 12,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w500,
    color: AppPalette.textMuted,
  );
}

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.accentGreen,
      brightness: Brightness.light,
    );
    return _buildTheme(colorScheme, isDark: false);
  }

  static ThemeData dark() {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: AppPalette.accentGreen,
      onPrimary: Color(0xFF032204),
      secondary: AppPalette.accentGreen,
      onSecondary: Color(0xFF032204),
      error: Color(0xFFFF6B6B),
      onError: Color(0xFFFFFFFF),
      surface: AppPalette.surface,
      onSurface: AppPalette.textPrimary,
    ).copyWith(
      onSurfaceVariant: AppPalette.textMuted,
      outline: AppPalette.outline,
      outlineVariant: AppPalette.outlineSoft,
      surfaceContainerLow: AppPalette.surface,
      surfaceContainer: AppPalette.surfaceAlt,
      surfaceContainerHighest: AppPalette.surfaceAlt,
    );
    return _buildTheme(
      colorScheme,
      isDark: true,
    );
  }

  static ThemeData _buildTheme(
    ColorScheme colorScheme, {
    required bool isDark,
  }) {
    final baseText = isDark
        ? Typography.material2021().white
        : Typography.material2021().black;
    final textTheme = baseText.copyWith(
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: baseText.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        height: 1.35,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        height: 1.35,
      ),
      bodySmall: baseText.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: baseText.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor:
          isDark ? AppPalette.backgroundDark : colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lg,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.md,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.md,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.md,
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.4,
          ),
        ),
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.xl),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
      ),
    );
  }
}
