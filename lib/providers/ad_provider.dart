import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ad_service.dart';

class AdProvider extends ChangeNotifier {
  final AdService _adService = AdService();
  late SharedPreferences _prefs;
  
  // Ad counters for strategic ad placement
  int _pageViewCount = 0;
  int _actionCount = 0;
  int _totalAppOpenCount = 0;
  bool _isPremium = false;  // No ads for premium users
  int _interstitialAttemptCount = 0;
  
  // Flag to track consent has been requested
  bool _consentRequested = false;

  // Getters
  bool get isPremium => _isPremium;
  bool get isBannerAdLoaded => _adService.isBannerAdLoaded;
  BannerAd? get bannerAd => _adService.bannerAd;
  bool get isInterstitialAdLoaded => _adService.isInterstitialAdLoaded;
  bool get isRewardedAdLoaded => _adService.isRewardedAdLoaded;
  bool get consentRequested => _consentRequested;

  // Initialize
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Retrieve counters and premium status from shared preferences
    _pageViewCount = _prefs.getInt('page_view_count') ?? 0;
    _actionCount = _prefs.getInt('action_count') ?? 0;
    _totalAppOpenCount = _prefs.getInt('total_app_open_count') ?? 0;
    _isPremium = _prefs.getBool('is_premium') ?? false;
    _consentRequested = _prefs.getBool('consent_requested') ?? false;
    
    // Initialize AdMob
    await _adService.initialize();
    
    // Increment app open count
    _totalAppOpenCount++;
    _prefs.setInt('total_app_open_count', _totalAppOpenCount);
    
    // If not premium, load ads
    if (!_isPremium) {
      loadAds();
    }
    
    notifyListeners();
  }
  
  // Load all ad types
  void loadAds() {
    if (_isPremium) return;
    
    _adService.loadBannerAd();
    _adService.loadInterstitialAd();
    _adService.loadRewardedAd();
    
    notifyListeners();
  }
  
  // Set premium status (e.g., after purchase)
  Future<void> setPremiumStatus(bool status) async {
    _isPremium = status;
    await _prefs.setBool('is_premium', status);
    
    if (_isPremium) {
      // Dispose all ads when premium
      _adService.disposeAds();
    } else {
      // Reload ads if not premium
      loadAds();
    }
    
    notifyListeners();
  }
  
  // Track page view and show interstitial strategically
  Future<void> trackPageView() async {
    if (_isPremium) return;
    
    _pageViewCount++;
    await _prefs.setInt('page_view_count', _pageViewCount);
    
    // Show interstitial ad every 8 page views, but not on first session
    if (_totalAppOpenCount > 1 && _pageViewCount % 8 == 0) {
      await showInterstitialAd();
    }
  }
  
  // Track user actions and show interstitial strategically
  Future<void> trackAction() async {
    if (_isPremium) return;
    
    _actionCount++;
    await _prefs.setInt('action_count', _actionCount);
    
    // Show interstitial after multiple meaningful actions (e.g., search, add field)
    if (_actionCount % 12 == 0 && _totalAppOpenCount > 1) {
      await showInterstitialAd();
    }
  }
  
  // Show interstitial with retry logic and rate limiting
  Future<bool> showInterstitialAd() async {
    if (_isPremium) return false;
    
    bool success = await _adService.showInterstitialAd();
    
    // If ad not ready, try to reload for next time
    if (!success) {
      _interstitialAttemptCount++;
      
      // If we've tried several times, wait longer before trying again
      if (_interstitialAttemptCount >= 3) {
        _interstitialAttemptCount = 0;
      } else {
        _adService.loadInterstitialAd();
      }
    } else {
      _interstitialAttemptCount = 0;
    }
    
    return success;
  }
  
  // Show rewarded ad with callback
  Future<bool> showRewardedAd({required Function(RewardItem) onRewarded}) async {
    return await _adService.showRewardedAd(onRewarded: onRewarded);
  }
  
  // Set consent requested flag
  Future<void> setConsentRequested(bool requested) async {
    _consentRequested = requested;
    await _prefs.setBool('consent_requested', requested);
    notifyListeners();
  }
  
  @override
  void dispose() {
    _adService.disposeAds();
    super.dispose();
  }
}