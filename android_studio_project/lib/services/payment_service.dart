import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle in-app purchases and subscriptions
/// 
/// In a real app, this would use packages like 'in_app_purchase' or 'purchases_flutter'
/// This is a simplified version for demonstration
class PaymentService {
  // Constants for storage keys
  static const String _premiumStatusKey = 'isPremium';
  static const String _subscriptionEndDateKey = 'subscriptionEndDate';
  
  /// Initializes the payment service and checks subscription status
  static Future<void> initialize() async {
    // Check if subscription has expired
    await _checkSubscriptionStatus();
  }
  
  /// Purchases a subscription product
  /// 
  /// Returns true if purchase was successful
  static Future<bool> purchase(String productId) async {
    try {
      // In a real app, this would initiate the purchase flow
      // and handle the payment gateway interaction
      
      // For demo purposes we'll simulate success and save to prefs
      await _savePurchase(productId);
      return true;
    } catch (e) {
      debugPrint('Error during purchase: $e');
      return false;
    }
  }
  
  /// Restores previous purchases
  /// 
  /// Returns true if any active subscription was restored
  static Future<bool> restorePurchases() async {
    try {
      // For demo purposes, check if we've saved a purchase
      final prefs = await SharedPreferences.getInstance();
      final endDateStr = prefs.getString(_subscriptionEndDateKey);
      
      if (endDateStr != null) {
        final endDate = DateTime.parse(endDateStr);
        final isActive = endDate.isAfter(DateTime.now());
        
        if (isActive) {
          await prefs.setBool(_premiumStatusKey, true);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }
  
  /// Check if the user has an active subscription
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumStatusKey) ?? false;
  }
  
  /// Updates premium status based on subscription end date
  static Future<void> _checkSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final endDateStr = prefs.getString(_subscriptionEndDateKey);
    
    if (endDateStr != null) {
      final endDate = DateTime.parse(endDateStr);
      final isActive = endDate.isAfter(DateTime.now());
      
      await prefs.setBool(_premiumStatusKey, isActive);
    }
  }
  
  /// Saves a purchase to shared preferences
  static Future<void> _savePurchase(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Set premium status to true
    await prefs.setBool(_premiumStatusKey, true);
    
    // Calculate end date based on product
    final now = DateTime.now();
    final DateTime endDate;
    
    if (productId == 'monthly_subscription') {
      endDate = DateTime(now.year, now.month + 1, now.day);
    } else {
      endDate = DateTime(now.year + 1, now.month, now.day);
    }
    
    // Save end date
    await prefs.setString(_subscriptionEndDateKey, endDate.toIso8601String());
  }
}