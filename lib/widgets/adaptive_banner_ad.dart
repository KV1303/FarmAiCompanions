import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';
import '../providers/ad_provider.dart';

class AdaptiveBannerAd extends StatefulWidget {
  final bool isTopBanner;
  
  const AdaptiveBannerAd({
    Key? key,
    this.isTopBanner = false,
  }) : super(key: key);

  @override
  State<AdaptiveBannerAd> createState() => _AdaptiveBannerAdState();
}

class _AdaptiveBannerAdState extends State<AdaptiveBannerAd> {
  BannerAd? _adaptiveBannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAdaptiveBannerAd();
  }

  @override
  void dispose() {
    _adaptiveBannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAdaptiveBannerAd() async {
    final AdProvider adProvider = Provider.of<AdProvider>(context, listen: false);
    
    // Don't load ads for premium users
    if (adProvider.isPremium) {
      return;
    }
    
    // Get the current orientation and size of the device
    final AnchoredAdaptiveBannerAdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );
    
    if (size == null) {
      debugPrint('Unable to get AnchoredAdaptiveBannerAdSize');
      return;
    }

    _adaptiveBannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Adaptive banner ad failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    );

    return _adaptiveBannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    
    if (adProvider.isPremium) {
      return const SizedBox.shrink(); // No ads for premium users
    }
    
    if (!_isAdLoaded || _adaptiveBannerAd == null) {
      // Return an empty space with the approximate height of a banner
      return SizedBox(
        height: 60,
        child: Center(
          child: widget.isTopBanner 
              ? const SizedBox.shrink()
              : const Text(
                  'Ad Space',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
        ),
      );
    }

    return Container(
      color: widget.isTopBanner ? Colors.transparent : Colors.grey[200],
      width: _adaptiveBannerAd!.size.width.toDouble(),
      height: _adaptiveBannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _adaptiveBannerAd!),
    );
  }
}