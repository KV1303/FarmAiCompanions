import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Singleton pattern
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Testing Ad Units - Replace with actual IDs for production
  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }
    // Replace with your actual production ad unit IDs
    return Platform.isAndroid
        ? 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'
        : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      }
    }
    // Replace with your actual production ad unit IDs
    return Platform.isAndroid
        ? 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'
        : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313';
      }
    }
    // Replace with your actual production ad unit IDs
    return Platform.isAndroid
        ? 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'
        : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  }

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  DateTime? _lastInterstitialShown;

  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  // Rewarded Ad
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;

  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  // Initialize Mobile Ads SDK
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Load Banner Ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdLoaded = true;
          debugPrint('Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: ${error.message}');
          ad.dispose();
          _bannerAd = null;
          _isBannerAdLoaded = false;
          
          // Retry after delay
          Future.delayed(const Duration(minutes: 1), () {
            if (_bannerAd == null) {
              loadBannerAd();
            }
          });
        },
      ),
    );

    _bannerAd?.load();
  }

  // Dispose Banner Ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  // Load Interstitial Ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint('Interstitial ad loaded successfully');

          // Set up full screen callback
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _isInterstitialAdLoaded = false;
              _interstitialAd = null;
              _lastInterstitialShown = DateTime.now();
              ad.dispose();
              
              // Reload after showing
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Failed to show interstitial ad: ${error.message}');
              _isInterstitialAdLoaded = false;
              _interstitialAd = null;
              ad.dispose();
              
              // Reload after failing to show
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: ${error.message}');
          _isInterstitialAdLoaded = false;
          
          // Retry after delay
          Future.delayed(const Duration(minutes: 1), () {
            loadInterstitialAd();
          });
        },
      ),
    );
  }

  // Show Interstitial Ad with rate limiting
  Future<bool> showInterstitialAd() async {
    // Rate limit - don't show interstitials too frequently
    if (_lastInterstitialShown != null) {
      final difference = DateTime.now().difference(_lastInterstitialShown!);
      if (difference.inMinutes < 3) {
        debugPrint('Skipping interstitial ad due to rate limiting');
        return false;
      }
    }

    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      await _interstitialAd?.show();
      return true;
    } else {
      debugPrint('Interstitial ad not ready');
      loadInterstitialAd(); // Try to load for next time
      return false;
    }
  }

  // Load Rewarded Ad
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          debugPrint('Rewarded ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: ${error.message}');
          _isRewardedAdLoaded = false;
          
          // Retry after delay
          Future.delayed(const Duration(minutes: 1), () {
            loadRewardedAd();
          });
        },
      ),
    );
  }

  // Show Rewarded Ad
  Future<bool> showRewardedAd({required Function(RewardItem) onRewarded}) async {
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          ad.dispose();
          
          // Reload after showing
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Failed to show rewarded ad: ${error.message}');
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          ad.dispose();
          
          // Reload after failing to show
          loadRewardedAd();
        },
      );

      await _rewardedAd?.show(
        onUserEarnedReward: (_, reward) {
          onRewarded(reward);
        },
      );
      return true;
    } else {
      debugPrint('Rewarded ad not ready');
      loadRewardedAd(); // Try to load for next time
      return false;
    }
  }

  // Dispose all ads
  void disposeAds() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _isRewardedAdLoaded = false;
  }
}