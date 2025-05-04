import 'package:flutter/material.dart';

/// Color constants used throughout the app
class AppColors {
  // Primary theme colors
  static const Color primaryColor = Color(0xFF2E7D32); // Forest green
  static const Color secondaryColor = Color(0xFF558B2F); // Lighter green
  static const Color accentColor = Color(0xFFF9A825); // Amber/gold
  
  // Background and surface colors
  static const Color lightBackground = Color(0xFFF9F7F2); // Light cream
  static const Color cardBackground = Colors.white;
  
  // Text colors
  static const Color darkText = Color(0xFF2E2E2E);
  static const Color lightText = Colors.white;
  static const Color disabledText = Color(0xFF9E9E9E);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color info = Color(0xFF2196F3);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  
  // Weather specific colors
  static const Color weatherBackground = Color(0xFFFFD687);
  
  // Specialized feature colors
  static const Color disease = Color(0xFFE57373); // Light red for disease detection
  static const Color irrigation = Color(0xFF4FC3F7); // Light blue for irrigation
  static const Color fertilizer = Color(0xFF81C784); // Light green for fertilizer
  static const Color market = Color(0xFFFFB74D); // Light orange for market prices
  
  // Premium/subscription colors
  static const Color premium = Color(0xFFAA00FF); // Purple for premium features
  static const Color trial = Color(0xFF673AB7); // Darker purple for trial
  
  // Ad-related colors
  static const Color adLabel = Color(0xFFFFD700); // Gold for ad labels
  static const Color adBackground = Color(0xFFF0F0F0); // Light grey for ad backgrounds
  static const Color adCta = Color(0xFF1B5E20); // Dark green for ad CTAs
  
  // Chat-related colors
  static const Color userMessage = Color(0xFFE3F2FD); // Light blue for user messages
  static const Color botMessage = Color(0xFFE9F5E9); // Light green for bot messages
}