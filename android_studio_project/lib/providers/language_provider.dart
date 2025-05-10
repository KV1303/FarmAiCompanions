import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', 'US');
  
  Locale get currentLocale => _currentLocale;
  
  LanguageProvider() {
    loadSavedLanguage();
  }
  
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.prefLanguage);
    
    if (languageCode != null) {
      if (languageCode == 'hi') {
        _currentLocale = const Locale('hi', 'IN');
      } else {
        _currentLocale = const Locale('en', 'US');
      }
      notifyListeners();
    }
  }
  
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == 'hi') {
      _currentLocale = const Locale('hi', 'IN');
    } else {
      _currentLocale = const Locale('en', 'US');
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLanguage, languageCode);
    
    notifyListeners();
  }
  
  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isHindi => _currentLocale.languageCode == 'hi';
}
