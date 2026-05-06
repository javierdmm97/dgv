import 'package:flutter/material.dart';

/// DGT (Dirección General de Tráfico) color palette
/// High-contrast colors for drunk-proof UI
class DGTColors {
  DGTColors._();

  // Primary Colors
  static const primary = Color(0xFF0F5993); // DGT Blue
  static const background = Color(0xFFF6F4F5); // Light Gray
  static const licenseId = Color(0xFFF3E8EC); // Light Pink (for ID card)

  // Traffic Light Colors (for feedback)
  static const green = Color(0xFFD2D667); // Lime Green
  static const yellow = Color(0xFFF4E944); // Bright Yellow
  static const orange = Color(0xFFF3910E); // Traffic Orange
  static const red = Color(0xFFEF6B6A); // Violation Red

  // Surface Colors
  static const surface = Color(0xFFFFFFFF); // White for cards
  static const surfaceDark = Color(0xFF1A1A1A); // Dark surface

  // Text Colors
  static const textPrimary = Color(0xFF000000); // Black text
  static const textSecondary = Color(0xFF666666); // Gray text
  static const textOnPrimary = Color(0xFFFFFFFF); // White text on primary

  // Status Colors
  static const success = green;
  static const warning = yellow;
  static const error = red;
  static const info = primary;

  // Siren Colors (for animations)
  static const sirenRed = Color(0xFFFF0000);
  static const sirenBlue = Color(0xFF0000FF);
}
