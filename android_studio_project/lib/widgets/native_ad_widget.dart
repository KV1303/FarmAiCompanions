import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class NativeAdWidget extends StatefulWidget {
  final bool small;
  
  const NativeAdWidget({
    Key? key, 
    this.small = false,
  }) : super(key: key);

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  
  // Get test ad unit IDs (replace with actual ones in production)
  String get _adUnitId {
    if (kDebugMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'ca-app-pub-3940256099942544/2247696110';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return 'ca-app-pub-3940256099942544/3986624511';
      }
    }
    // Replace with your actual production ad unit IDs
    return defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'
        : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  }

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      factoryId: widget.small ? 'smallNativeAd' : 'largeNativeAd',
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native ad failed to load: ${error.message}');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );

    _nativeAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _nativeAd == null) {
      return Container(
        height: widget.small ? 100 : 350,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: const Center(
          child: Text(
            'विज्ञापन लोड हो रहा है...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      height: widget.small ? 100 : 350,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}