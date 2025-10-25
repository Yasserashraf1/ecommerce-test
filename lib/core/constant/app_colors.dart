import 'package:flutter/material.dart';

class AppColors {
  // Primary colors matching your logo
  static const Color primaryTeal = Color(0xFF00BCD4);
  static const Color secondaryTeal = Color(0xFF26A69A);
  static const Color lightTeal = Color(0xFF4DD0E1);
  static const Color extraLightTeal = Color(0xFFE0F7FA);

  // Neutral colors
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color mediumText = Color(0xFF666666);
  static const Color lightText = Color(0xFF999999);
  static const Color background = Color(0xFFF8FFFE);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color borderGray = Color(0xFFE0E0E0);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryTeal, secondaryTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFAFAFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// Extension to easily access theme colors
extension AppColorsExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}