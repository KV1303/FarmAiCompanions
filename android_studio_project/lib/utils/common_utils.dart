import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CommonUtils {
  // Constants for shared preferences keys
  static const String _unlockedArticlesKey = 'unlockedArticles';

  /// Save an article ID as unlocked for the current user
  static Future<void> saveUnlockedArticle(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedArticles = getUnlockedArticlesFromPrefs(prefs);
    
    if (!unlockedArticles.contains(articleId)) {
      unlockedArticles.add(articleId);
      await prefs.setStringList(_unlockedArticlesKey, unlockedArticles);
    }
  }
  
  /// Check if an article has been unlocked by the user
  static Future<bool> isArticleUnlocked(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedArticles = getUnlockedArticlesFromPrefs(prefs);
    return unlockedArticles.contains(articleId);
  }
  
  /// Get the list of unlocked article IDs
  static Future<List<String>> getUnlockedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    return getUnlockedArticlesFromPrefs(prefs);
  }
  
  /// Helper to get unlocked articles from the provided preferences instance
  static List<String> getUnlockedArticlesFromPrefs(SharedPreferences prefs) {
    return prefs.getStringList(_unlockedArticlesKey) ?? [];
  }
  
  /// Format a date string from ISO format to a more readable format
  static String formatDateString(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate; // Return original if parsing fails
    }
  }
  
  /// Shorten a long text to a specified length with ellipsis
  static String shortenText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Save data to local storage as JSON
  static Future<bool> saveDataToLocalStorage(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving data to local storage: $e');
      return false;
    }
  }
  
  /// Load JSON data from local storage
  static Future<dynamic> loadDataFromLocalStorage(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      print('Error loading data from local storage: $e');
      return null;
    }
  }
}