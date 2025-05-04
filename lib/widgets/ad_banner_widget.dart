import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/ad_provider.dart';

class AdBannerWidget extends StatelessWidget {
  final bool isTopBanner;
  
  const AdBannerWidget({
    Key? key,
    this.isTopBanner = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    
    if (adProvider.isPremium) {
      return const SizedBox.shrink(); // No ads for premium users
    }
    
    if (!adProvider.isBannerAdLoaded || adProvider.bannerAd == null) {
      // Display a placeholder while the ad is loading
      return Container(
        height: 50, // Standard banner ad height
        color: Colors.transparent,
        alignment: Alignment.center,
        child: const SizedBox.shrink(),
      );
    }
    
    // Create an AdWidget to display the loaded BannerAd
    return Container(
      height: adProvider.bannerAd!.size.height.toDouble(),
      width: adProvider.bannerAd!.size.width.toDouble(),
      color: isTopBanner ? Colors.transparent : Colors.grey[200],
      alignment: Alignment.center,
      child: AdWidget(ad: adProvider.bannerAd!),
    );
  }
}