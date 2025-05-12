import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'subscription_service.dart';

class AdService {
  // Banner ad unit IDs
  static const String bannerAdUnitId = 'ca-app-pub-3734294344200337/3068736185';
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  
  // Interstitial ad unit IDs
  static const String interstitialAdUnitId = 'ca-app-pub-3734294344200337/5398170069';
  static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  // Mode flag
  final bool testMode;
  
  // Interstitial ad instance
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  
  // Cooldown timer for interstitial ads
  DateTime? _lastInterstitialAdShown;
  static const int interstitialCooldownSeconds = 30;
  
  // Subscription service to check if ads should be shown
  final SubscriptionService _subscriptionService;
  
  AdService({
    required SubscriptionService subscriptionService,
    this.testMode = false,
  }) : _subscriptionService = subscriptionService {
    _initInterstitialAd();
  }
  
  // Get the banner ad unit ID based on mode
  String get bannerAdId => testMode ? testBannerAdUnitId : bannerAdUnitId;
  
  // Get the interstitial ad unit ID based on mode
  String get interstitialAdId => testMode ? testInterstitialAdUnitId : interstitialAdUnitId;
  
  // Initialize interstitial ad
  void _initInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          // Set callback for ad closure
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _initInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _initInterstitialAd(); // Try to load again
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: ${error.message}');
          _isInterstitialAdReady = false;
          // Retry after a delay
          Timer(const Duration(minutes: 1), _initInterstitialAd);
        },
      ),
    );
  }
  
  // Show interstitial ad if ready and not on cooldown
  Future<bool> showInterstitialAd(BuildContext context) async {
    // Check if user is subscribed - don't show ads to subscribers
    bool isSubscribed = await _subscriptionService.hasActiveSubscription();
    if (isSubscribed) return false;
    
    // Check if ad is ready
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      _initInterstitialAd();
      return false;
    }
    
    // Check cooldown timer
    if (_lastInterstitialAdShown != null) {
      final difference = DateTime.now().difference(_lastInterstitialAdShown!);
      if (difference.inSeconds < interstitialCooldownSeconds) {
        print('Interstitial ad on cooldown. ${interstitialCooldownSeconds - difference.inSeconds} seconds remaining.');
        return false;
      }
    }
    
    // Show the ad
    try {
      await _interstitialAd!.show();
      _lastInterstitialAdShown = DateTime.now();
      _isInterstitialAdReady = false;
      return true;
    } catch (e) {
      print('Error showing interstitial ad: $e');
      return false;
    }
  }
  
  // Create a banner ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Banner ad failed to load: ${error.message}');
        },
      ),
    );
  }
  
  // Load and return a banner ad widget
  Future<Widget> loadBanner({AdSize size = AdSize.banner}) async {
    // Check if user is subscribed - don't show ads to subscribers
    bool isSubscribed = await _subscriptionService.hasActiveSubscription();
    if (isSubscribed) {
      // Return empty container of the same size
      return SizedBox(
        height: size.height.toDouble(),
        width: size.width.toDouble(),
      );
    }
    
    final BannerAd banner = BannerAd(
      adUnitId: bannerAdId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Banner ad failed to load: ${error.message}');
        },
      ),
    );
    
    try {
      await banner.load();
      return SizedBox(
        height: banner.size.height.toDouble(),
        width: banner.size.width.toDouble(),
        child: AdWidget(ad: banner),
      );
    } catch (e) {
      print('Error loading banner ad: $e');
      return SizedBox(
        height: size.height.toDouble(),
        width: size.width.toDouble(),
      );
    }
  }
  
  // Dispose ads when no longer needed
  void dispose() {
    _interstitialAd?.dispose();
  }
}