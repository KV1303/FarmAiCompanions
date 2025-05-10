import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider class that manages ad state and premium subscription status
class AdProvider with ChangeNotifier {
  bool _isPremium = false;
  bool _hasConsent = false;
  bool _adsInitialized = false;
  DateTime? _trialEndDate;
  int _adFrequencyCap = 3; // Number of actions before showing interstitial
  int _currentActionCount = 0;
  
  // Getters
  bool get isPremium => _isPremium;
  bool get hasConsent => _hasConsent;
  bool get adsInitialized => _adsInitialized;
  bool get isInTrial => _trialEndDate != null && _trialEndDate!.isAfter(DateTime.now());
  int get daysLeftInTrial {
    if (_trialEndDate == null) return 0;
    final difference = _trialEndDate!.difference(DateTime.now());
    return difference.inDays >= 0 ? difference.inDays + 1 : 0; // +1 to include today
  }
  
  // Constructor
  AdProvider() {
    _loadPreferences();
  }
  
  /// Load ad preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('isPremium') ?? false;
    _hasConsent = prefs.getBool('adConsent') ?? false;
    
    // Load trial end date if it exists
    final trialEndMillis = prefs.getInt('trialEndDate');
    if (trialEndMillis != null) {
      _trialEndDate = DateTime.fromMillisecondsSinceEpoch(trialEndMillis);
    }
    
    _adFrequencyCap = prefs.getInt('adFrequencyCap') ?? 3;
    _currentActionCount = prefs.getInt('currentActionCount') ?? 0;
    
    notifyListeners();
  }
  
  /// Save ad preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', _isPremium);
    await prefs.setBool('adConsent', _hasConsent);
    
    if (_trialEndDate != null) {
      await prefs.setInt('trialEndDate', _trialEndDate!.millisecondsSinceEpoch);
    } else {
      await prefs.remove('trialEndDate');
    }
    
    await prefs.setInt('adFrequencyCap', _adFrequencyCap);
    await prefs.setInt('currentActionCount', _currentActionCount);
  }
  
  /// Set user's premium status
  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
    _savePreferences();
    notifyListeners();
  }
  
  /// Set user's consent for personalized ads
  void setAdConsent(bool hasConsent) {
    _hasConsent = hasConsent;
    _savePreferences();
    notifyListeners();
  }
  
  /// Start a free trial
  void startFreeTrial(int durationInDays) {
    if (!_isPremium) {
      _trialEndDate = DateTime.now().add(Duration(days: durationInDays));
      _savePreferences();
      notifyListeners();
    }
  }
  
  /// End the trial period
  void endTrial() {
    _trialEndDate = null;
    _savePreferences();
    notifyListeners();
  }
  
  /// Track user action for frequency capping
  bool shouldShowInterstitial() {
    if (_isPremium) return false;
    
    _currentActionCount++;
    _savePreferences();
    
    if (_currentActionCount >= _adFrequencyCap) {
      _currentActionCount = 0;
      _savePreferences();
      return true;
    }
    
    return false;
  }
  
  /// Initialize ads (would connect with real AdMob in production)
  void initializeAds() {
    // In a real app, this would initialize AdMob SDK
    _adsInitialized = true;
    notifyListeners();
  }
  
  /// Reset action counter
  void resetActionCounter() {
    _currentActionCount = 0;
    _savePreferences();
  }
  
  /// Update ad frequency capping
  void setAdFrequencyCap(int cap) {
    _adFrequencyCap = cap;
    _savePreferences();
    notifyListeners();
  }
}