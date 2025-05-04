import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ad_service.dart';

class AdProvider with ChangeNotifier {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isPremium = false;
  bool _personalizedAdsEnabled = true;
  bool _consentRequested = false;
  
  // Counters for ad frequency optimization
  int _pageViewCount = 0;
  int _userActionCount = 0;
  
  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  bool get isPremium => _isPremium;
  bool get personalizedAdsEnabled => _personalizedAdsEnabled;
  bool get consentRequested => _consentRequested;
  
  AdProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _consentRequested = prefs.getBool('adConsentRequested') ?? false;
    _personalizedAdsEnabled = prefs.getBool('personalizedAdsEnabled') ?? true;
    _isPremium = prefs.getBool('isPremium') ?? false;
    
    // If consent has been requested, initialize ads
    if (_consentRequested) {
      initializeAds(_personalizedAdsEnabled);
    }
    
    notifyListeners();
  }
  
  Future<void> setConsentRequested(bool value) async {
    _consentRequested = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adConsentRequested', value);
    notifyListeners();
  }
  
  Future<void> setPersonalizedAdsEnabled(bool value) async {
    _personalizedAdsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('personalizedAdsEnabled', value);
    notifyListeners();
  }
  
  Future<void> setPremiumStatus(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', value);
    
    // Dispose of ads if user becomes premium
    if (value) {
      _disposeAds();
    } else {
      // Reload ads if user is no longer premium
      _loadBannerAd();
      _loadInterstitialAd();
      _loadRewardedAd();
    }
    
    notifyListeners();
  }
  
  void initializeAds(bool personalizedAds) {
    if (_isPremium) return;
    
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }
  
  void _loadBannerAd() {
    if (_isPremium) return;
    
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(nonPersonalizedAds: !_personalizedAdsEnabled),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: ${error.message}');
          ad.dispose();
          _isBannerAdLoaded = false;
          notifyListeners();
          
          // Retry after a delay
          Future.delayed(const Duration(minutes: 1), _loadBannerAd);
        },
      ),
    );

    _bannerAd!.load();
  }

  void _loadInterstitialAd() {
    if (_isPremium) return;
    
    InterstitialAd.load(
      adUnitId: AdService.interstitialAdUnitId,
      request: AdRequest(nonPersonalizedAds: !_personalizedAdsEnabled),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          
          // Set full-screen callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdLoaded = false;
              _loadInterstitialAd(); // Reload for next time
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial ad failed to show: ${error.message}');
              ad.dispose();
              _isInterstitialAdLoaded = false;
              _loadInterstitialAd(); // Retry
            },
          );
          
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: ${error.message}');
          _isInterstitialAdLoaded = false;
          notifyListeners();
          
          // Retry after a delay
          Future.delayed(const Duration(minutes: 5), _loadInterstitialAd);
        },
      ),
    );
  }
  
  void _loadRewardedAd() {
    if (_isPremium) return;
    
    RewardedAd.load(
      adUnitId: AdService.rewardedAdUnitId,
      request: AdRequest(nonPersonalizedAds: !_personalizedAdsEnabled),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: ${error.message}');
          _isRewardedAdLoaded = false;
          notifyListeners();
          
          // Retry after a delay
          Future.delayed(const Duration(minutes: 5), _loadRewardedAd);
        },
      ),
    );
  }
  
  Future<bool> showInterstitialAd() async {
    if (_isPremium) return false;
    
    // Implement frequency capping
    if (_pageViewCount < 3) return false; // Don't show until user has visited at least 3 pages
    
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      await _interstitialAd!.show();
      _pageViewCount = 0; // Reset page counter
      _userActionCount = 0; // Reset action counter
      _isInterstitialAdLoaded = false;
      _loadInterstitialAd(); // Reload the ad for next time
      return true;
    } else {
      // If ad isn't loaded, try to load it for next time
      _loadInterstitialAd();
      return false;
    }
  }
  
  Future<bool> showRewardedAd({required Function(RewardItem) onRewarded}) async {
    if (_isPremium) return false;
    
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      await _rewardedAd!.show(onUserEarnedReward: (_, reward) {
        onRewarded(reward);
      });
      
      _isRewardedAdLoaded = false;
      _loadRewardedAd(); // Reload the ad
      return true;
    } else {
      // If ad isn't loaded, try to load it for next time
      _loadRewardedAd();
      return false;
    }
  }
  
  Future<void> trackPageView() async {
    if (_isPremium) return;
    
    _pageViewCount++;
    notifyListeners();
  }
  
  Future<void> trackAction() async {
    if (_isPremium) return;
    
    _userActionCount++;
    notifyListeners();
  }
  
  void _disposeAds() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _isRewardedAdLoaded = false;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _disposeAds();
    super.dispose();
  }
}