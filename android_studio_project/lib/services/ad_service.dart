import 'package:flutter/foundation.dart';

/// Service class to centralize ad unit IDs and ad-related configurations
class AdService {
  // Test ad unit IDs (use in development only)
  static const String _testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedAdUnitIdIOS = 'ca-app-pub-3940256099942544/1712485313';

  // Production ad unit IDs - replace with your actual Ad Unit IDs from AdMob console
  static const String _prodBannerAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodBannerAdUnitIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodInterstitialAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodInterstitialAdUnitIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodRewardedAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodRewardedAdUnitIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  /// Returns the appropriate banner ad unit ID based on platform and environment
  static String get bannerAdUnitId {
    if (kDebugMode) {
      // Return test ad unit ID in debug mode
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _testBannerAdUnitIdAndroid;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _testBannerAdUnitIdIOS;
      }
    } else {
      // Return production ad unit ID in release mode
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _prodBannerAdUnitIdAndroid;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _prodBannerAdUnitIdIOS;
      }
    }
    return _testBannerAdUnitIdAndroid; // Default fallback
  }

  /// Returns the appropriate interstitial ad unit ID based on platform and environment
  static String get interstitialAdUnitId {
    if (kDebugMode) {
      // Return test ad unit ID in debug mode
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _testInterstitialAdUnitIdAndroid;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _testInterstitialAdUnitIdIOS;
      }
    } else {
      // Return production ad unit ID in release mode
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _prodInterstitialAdUnitIdAndroid;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _prodInterstitialAdUnitIdIOS;
      }
    }
    return _testInterstitialAdUnitIdAndroid; // Default fallback
  }

  /// Returns the appropriate rewarded ad unit ID based on platform and environment
  static String get rewardedAdUnitId {
    if (kDebugMode) {
      // Return test ad unit ID in debug mode
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _testRewardedAdUnitIdAndroid;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _testRewardedAdUnitIdIOS;
      }
    } else {
      // Return production ad unit ID in release mode
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _prodRewardedAdUnitIdAndroid;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _prodRewardedAdUnitIdIOS;
      }
    }
    return _testRewardedAdUnitIdAndroid; // Default fallback
  }
  
  /// Ad frequency cap settings
  static const int minPagesBetweenInterstitials = 3;
  static const int minActionsBetweenInterstitials = 5;
  static const int minTimeBetweenInterstitialsSecs = 120; // 2 minutes
  
  /// Banner ad position config
  static const bool showBannerAtTop = false;
  
  /// Returns whether banner ads should be shown in the given screen
  static bool shouldShowBannerInScreen(String screenName) {
    // Define screens where banner ads should NOT be shown
    const List<String> noBannerScreens = [
      'onboarding_screen',
      'splash_screen',
      'login_screen',
      'register_screen',
      'premium_upgrade_screen',
    ];
    
    return !noBannerScreens.contains(screenName);
  }
  
  /// Returns whether interstitial ads should be shown when leaving the given screen
  static bool shouldShowInterstitialAfterScreen(String screenName) {
    // Define screens where interstitial ads should be shown when leaving
    const List<String> showInterstitialAfterScreens = [
      'disease_detection_result_screen',
      'weather_detail_screen',
      'market_prices_screen',
      'field_detail_screen',
    ];
    
    return showInterstitialAfterScreens.contains(screenName);
  }
}