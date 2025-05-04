import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';

class InterstitialAdHelper {
  /// Shows an interstitial ad at strategic points such as 
  /// when leaving a screen or after completing a significant action
  static Future<bool> showInterstitialAd(BuildContext context) async {
    // Get the ad provider
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    // Do not show ads for premium users
    if (adProvider.isPremium) {
      return false;
    }
    
    // Track page view (helps with strategic ad placement)
    await adProvider.trackPageView();
    
    // Let the provider decide if this is a good time to show an ad
    // This optimizes user experience by not showing ads too frequently
    return await adProvider.showInterstitialAd();
  }
  
  /// Shows an interstitial ad after a significant user action
  /// Returns true if ad was shown
  static Future<bool> showActionTriggeredAd(BuildContext context) async {
    // Get the ad provider
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    // Do not show ads for premium users
    if (adProvider.isPremium) {
      return false;
    }
    
    // Track action for strategic ad placement
    await adProvider.trackAction();
    
    // Will only show if enough actions have been performed
    return await adProvider.showInterstitialAd();
  }
}