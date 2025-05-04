import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  // Primary theme colors
  static const Color primaryColor = Color(0xFF1B5E20); // Dark green
  static const Color accentColor = Color(0xFFFF9800); // Orange
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light grey background
  static const Color textColor = Color(0xFF212121); // Dark text
  
  // UI element colors
  static const Color borderColor = Color(0xFFDDDDDD); // Light grey border
  static const Color errorColor = Color(0xFFB71C1C); // Red error color
  static const Color successColor = Color(0xFF388E3C); // Green success color
  static const Color warningColor = Color(0xFFFFA000); // Yellow warning color
  
  // Component-specific colors
  static const Color cardBackgroundColor = Colors.white;
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color disabledColor = Color(0xFFBDBDBD);
  static const Color hintTextColor = Color(0xFF9E9E9E);
  
  // Status colors
  static const Color activeStatusColor = Color(0xFF4CAF50);
  static const Color inactiveStatusColor = Color(0xFF9E9E9E);
  
  // Dark mode variants
  static const Color darkPrimaryColor = Color(0xFF2E7D32);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFEEEEEE);
  
  // Specific feature colors
  static const Color weatherBackgroundColor = Color(0xFF64B5F6);
  static const Color cropHealthColor = Color(0xFF66BB6A);
  static const Color soilMoistureColor = Color(0xFF795548);
  static const Color marketPricesColor = Color(0xFFFFA726);
  
  // Price indication colors
  static const Color priceIncreaseColor = Color(0xFF4CAF50);
  static const Color priceDecreaseColor = Color(0xFFF44336);
  static const Color priceStableColor = Color(0xFF9E9E9E);
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF1B5E20), // Dark green
    Color(0xFF4CAF50), // Light green
  ];
}