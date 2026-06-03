import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dgt_colors.dart';
import 'dgt_typography.dart';

/// DGT Theme Configuration
class DGTTheme {
  DGTTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: DGTColors.primary,
        secondary: DGTColors.yellow,
        surface: DGTColors.surface,
        error: DGTColors.error,
        onPrimary: DGTColors.textOnPrimary,
        onSecondary: DGTColors.textPrimary,
        onSurface: DGTColors.textPrimary,
        onError: DGTColors.textOnPrimary,
      ),

      // Scaffold
      scaffoldBackgroundColor: DGTColors.background,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: DGTColors.textOnPrimary,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: DGTTypography.displayLarge,
        displayMedium: DGTTypography.displayMedium,
        displaySmall: DGTTypography.displaySmall,
        headlineLarge: DGTTypography.headlineLarge,
        headlineMedium: DGTTypography.headlineMedium,
        headlineSmall: DGTTypography.headlineSmall,
        bodyLarge: DGTTypography.bodyLarge,
        bodyMedium: DGTTypography.bodyMedium,
        bodySmall: DGTTypography.bodySmall,
        labelLarge: DGTTypography.labelLarge,
        labelMedium: DGTTypography.labelMedium,
        labelSmall: DGTTypography.labelSmall,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 80),
          backgroundColor: DGTColors.primary,
          foregroundColor: DGTColors.textOnPrimary,
          textStyle: DGTTypography.buttonMedium,
          shape: const RoundedRectangleBorder(),
          elevation: 4,
        ),
      ),

      // Card
      cardTheme: const CardThemeData(
        color: DGTColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Input Decoration
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: DGTColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: DGTColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: DGTColors.textSecondary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: DGTColors.primary, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: DGTColors.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        labelStyle: DGTTypography.bodyMedium,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: DGTColors.primary,
        secondary: DGTColors.yellow,
        surface: DGTColors.surfaceDark,
        error: DGTColors.error,
        onPrimary: DGTColors.textOnPrimary,
        onSecondary: DGTColors.textPrimary,
        onSurface: DGTColors.textOnPrimary,
        onError: DGTColors.textOnPrimary,
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFF121212),

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: DGTColors.textOnPrimary,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: DGTTypography.displayLarge,
        displayMedium: DGTTypography.displayMedium,
        displaySmall: DGTTypography.displaySmall,
        headlineLarge: DGTTypography.headlineLarge,
        headlineMedium: DGTTypography.headlineMedium,
        headlineSmall: DGTTypography.headlineSmall,
        bodyLarge: DGTTypography.bodyLarge,
        bodyMedium: DGTTypography.bodyMedium,
        bodySmall: DGTTypography.bodySmall,
        labelLarge: DGTTypography.labelLarge,
        labelMedium: DGTTypography.labelMedium,
        labelSmall: DGTTypography.labelSmall,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 80),
          backgroundColor: DGTColors.primary,
          foregroundColor: DGTColors.textOnPrimary,
          textStyle: DGTTypography.buttonMedium,
          shape: const RoundedRectangleBorder(),
          elevation: 4,
        ),
      ),

      // Card
      cardTheme: const CardThemeData(
        color: DGTColors.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Input Decoration
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: DGTColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: DGTColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: DGTColors.textSecondary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: DGTColors.primary, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: DGTColors.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        labelStyle: DGTTypography.bodyMedium,
      ),
    );
  }
}
