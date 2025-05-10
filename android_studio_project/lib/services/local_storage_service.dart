import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/field_model.dart';
import '../models/weather_model.dart';
import '../models/market_price_model.dart';
import '../models/disease_model.dart';

class LocalStorageService {
  static Future<void> init() async {
    // Initialize boxes
    await Hive.openBox<User>(AppConstants.userBox);
    await Hive.openBox<Field>(AppConstants.fieldBox);
    await Hive.openBox<Weather>(AppConstants.weatherBox);
    await Hive.openBox<MarketPrice>(AppConstants.marketPriceBox);
    await Hive.openBox<Disease>(AppConstants.diseaseBox);
  }

  // Shared Preferences methods for simple key-value storage
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefIsFirstTime) ?? true;
  }

  Future<void> setFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsFirstTime, value);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefAuthToken);
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefAuthToken, token);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefAuthToken);
    await prefs.remove(AppConstants.prefUserId);
  }

  // User methods
  Future<User?> getUser(String userId) async {
    try {
      final box = Hive.box<User>(AppConstants.userBox);
      return box.get(userId);
    } catch (e) {
      debugPrint('Error getting user from local storage: $e');
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    try {
      final box = Hive.box<User>(AppConstants.userBox);
      await box.put(user.id, user);
      
      // Also save userId to SharedPreferences for easy access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefUserId, user.id);
    } catch (e) {
      debugPrint('Error saving user to local storage: $e');
    }
  }

  // Field methods
  Future<List<Field>> getFields(String userId) async {
    try {
      final box = Hive.box<Field>(AppConstants.fieldBox);
      final fields = box.values.where((field) => field.ownerId == userId).toList();
      return fields;
    } catch (e) {
      debugPrint('Error getting fields from local storage: $e');
      return [];
    }
  }

  Future<void> saveFields(String userId, List<Field> fields) async {
    try {
      final box = Hive.box<Field>(AppConstants.fieldBox);
      
      // Clear existing fields for this user
      final keysToRemove = box.keys.where((key) {
        final field = box.get(key);
        return field != null && field.ownerId == userId;
      }).toList();
      
      for (final key in keysToRemove) {
        await box.delete(key);
      }
      
      // Save new fields
      for (final field in fields) {
        await box.put(field.id, field);
      }
    } catch (e) {
      debugPrint('Error saving fields to local storage: $e');
    }
  }

  // Weather methods
  Future<Weather?> getCurrentWeather() async {
    try {
      final box = Hive.box<Weather>(AppConstants.weatherBox);
      return box.get('current');
    } catch (e) {
      debugPrint('Error getting current weather from local storage: $e');
      return null;
    }
  }

  Future<void> saveCurrentWeather(Weather weather) async {
    try {
      final box = Hive.box<Weather>(AppConstants.weatherBox);
      await box.put('current', weather);
    } catch (e) {
      debugPrint('Error saving current weather to local storage: $e');
    }
  }

  Future<List<Weather>> getForecastWeather() async {
    try {
      final box = Hive.box<Weather>(AppConstants.weatherBox);
      final forecast = <Weather>[];
      
      for (int i = 0; i < 5; i++) {
        final weather = box.get('forecast_$i');
        if (weather != null) {
          forecast.add(weather);
        }
      }
      
      return forecast;
    } catch (e) {
      debugPrint('Error getting forecast weather from local storage: $e');
      return [];
    }
  }

  Future<void> saveForecastWeather(List<Weather> forecast) async {
    try {
      final box = Hive.box<Weather>(AppConstants.weatherBox);
      
      for (int i = 0; i < forecast.length; i++) {
        await box.put('forecast_$i', forecast[i]);
      }
    } catch (e) {
      debugPrint('Error saving forecast weather to local storage: $e');
    }
  }

  // Market price methods
  Future<List<MarketPrice>> getMarketPrices(String cropType) async {
    try {
      final box = Hive.box<MarketPrice>(AppConstants.marketPriceBox);
      final prices = box.values.where((price) => 
        price.cropName.toLowerCase() == cropType.toLowerCase()
      ).toList();
      
      return prices;
    } catch (e) {
      debugPrint('Error getting market prices from local storage: $e');
      return [];
    }
  }

  Future<void> saveMarketPrices(String cropType, List<MarketPrice> prices) async {
    try {
      final box = Hive.box<MarketPrice>(AppConstants.marketPriceBox);
      
      // Clear existing prices for this crop
      final keysToRemove = box.keys.where((key) {
        final price = box.get(key);
        return price != null && price.cropName.toLowerCase() == cropType.toLowerCase();
      }).toList();
      
      for (final key in keysToRemove) {
        await box.delete(key);
      }
      
      // Save new prices
      for (final price in prices) {
        await box.put(price.id, price);
      }
    } catch (e) {
      debugPrint('Error saving market prices to local storage: $e');
    }
  }

  Future<List<MarketPrice>> getHistoricalPrices(String cropType, String marketName) async {
    try {
      final box = Hive.box<MarketPrice>(AppConstants.marketPriceBox);
      final prices = box.values.where((price) => 
        price.cropName.toLowerCase() == cropType.toLowerCase() &&
        price.marketName == marketName &&
        price.id.startsWith('historical_')
      ).toList();
      
      return prices;
    } catch (e) {
      debugPrint('Error getting historical prices from local storage: $e');
      return [];
    }
  }

  Future<void> saveHistoricalPrices(String cropType, String marketName, List<MarketPrice> prices) async {
    try {
      final box = Hive.box<MarketPrice>(AppConstants.marketPriceBox);
      
      // Clear existing historical prices for this crop and market
      final keysToRemove = box.keys.where((key) {
        final price = box.get(key);
        return price != null && 
               price.cropName.toLowerCase() == cropType.toLowerCase() &&
               price.marketName == marketName &&
               price.id.startsWith('historical_');
      }).toList();
      
      for (final key in keysToRemove) {
        await box.delete(key);
      }
      
      // Save new historical prices
      for (final price in prices) {
        await box.put(price.id, price);
      }
    } catch (e) {
      debugPrint('Error saving historical prices to local storage: $e');
    }
  }

  // Disease methods
  Future<List<Disease>> getDiseases() async {
    try {
      final box = Hive.box<Disease>(AppConstants.diseaseBox);
      return box.values.toList();
    } catch (e) {
      debugPrint('Error getting diseases from local storage: $e');
      return [];
    }
  }

  Future<void> saveDiseases(List<Disease> diseases) async {
    try {
      final box = Hive.box<Disease>(AppConstants.diseaseBox);
      
      // Clear existing diseases
      await box.clear();
      
      // Save new diseases
      for (final disease in diseases) {
        await box.put(disease.id, disease);
      }
    } catch (e) {
      debugPrint('Error saving diseases to local storage: $e');
    }
  }
}
