import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFF2E7D32); // Dark green
  static const Color primaryLightColor = Color(0xFF4CAF50); // Green
  static const Color primaryDarkColor = Color(0xFF1B5E20); // Darker green
  
  // Accent colors
  static const Color accentColor = Color(0xFFFF8F00); // Amber
  static const Color accentLightColor = Color(0xFFFFB74D); // Light amber
  static const Color accentDarkColor = Color(0xFFF57C00); // Dark amber
  
  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  
  // Text colors
  static const Color textColor = Color(0xFF424242);
  static const Color textLightColor = Color(0xFF757575);
  static const Color textDarkColor = Color(0xFF212121);
  
  // Status colors
  static const Color successColor = Color(0xFF43A047);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF1976D2);
  
  // Other colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color disabledColor = Color(0xFFBDBDBD);
  
  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF2E7D32),
    Color(0xFF1976D2),
    Color(0xFFFF8F00),
    Color(0xFFD32F2F),
    Color(0xFF7B1FA2),
    Color(0xFF00796B),
  ];
  
  // NDVI color gradient
  static const List<Color> ndviColorGradient = [
    Color(0xFFE53935), // Red (poor vegetation)
    Color(0xFFFFB74D), // Orange (moderate vegetation)
    Color(0xFF7CB342), // Light green (good vegetation)
    Color(0xFF2E7D32), // Dark green (excellent vegetation)
  ];
}
