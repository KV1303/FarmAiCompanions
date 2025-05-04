import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A widget to display demo/test ads when real AdMob is not available
/// Use this widget during development to visualize how ads will appear
class TestAdDisplay extends StatelessWidget {
  final AdType adType;
  final VoidCallback? onPressed;
  final VoidCallback? onClosed;
  
  const TestAdDisplay({
    Key? key,
    required this.adType,
    this.onPressed,
    this.onClosed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (adType) {
      case AdType.banner:
        return _buildBannerAd();
      case AdType.interstitial:
        return _buildInterstitialAd(context);
      case AdType.rewarded:
        return _buildRewardedAd(context);
      case AdType.native:
        return _buildNativeAd();
    }
  }
  
  Widget _buildBannerAd() {
    return Container(
      height: 50,
      color: Colors.grey[200],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                color: AppColors.accentColor.withOpacity(0.3),
                child: const Icon(
                  Icons.agriculture,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'आधुनिक खेती के उपकरण',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'अपनी फसल की उपज बढ़ाएं',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'देखें',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.yellow[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'विज्ञापन',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInterstitialAd(BuildContext context) {
    // This would normally be shown as a full-screen dialog
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              // Ad content
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with label
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.yellow[700],
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'विज्ञापन',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'FarmAssistAI',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ad image
                  Container(
                    height: 200,
                    color: AppColors.primaryColor.withOpacity(0.2),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.agriculture_outlined,
                            size: 80,
                            color: AppColors.primaryColor.withOpacity(0.8),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'आधुनिक खेती की तकनीकें अपनाएं',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ट्रैक्टर किराए पर उपलब्ध',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Ad text
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'आधुनिक कृषि उपकरण',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'हमारे पास सभी प्रकार के उन्नत कृषि उपकरण किराए पर उपलब्ध हैं। अपनी फसल की पैदावार बढ़ाएं और लागत कम करें।',
                        ),
                      ],
                    ),
                  ),
                  // CTA button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onPressed,
                      child: const Text('अभी संपर्क करें'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              // Close button
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onClosed != null) {
                      onClosed!();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardedAd(BuildContext context) {
    // Similar to interstitial but with reward messaging
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              // Ad content
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with label
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.purple,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'रिवॉर्ड विज्ञापन',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'FarmAssistAI',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Reward message
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.purple[100],
                    child: const Row(
                      children: [
                        Icon(Icons.card_giftcard, color: Colors.purple),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'इस विज्ञापन को पूरा देखें और 1 दिन की प्रीमियम सदस्यता पाएं!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ad image
                  Container(
                    height: 180,
                    color: Colors.blue.withOpacity(0.2),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 80,
                            color: Colors.blue.withOpacity(0.8),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'स्वचालित सिंचाई प्रणाली',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'पानी की बचत करें और फसल की उपज बढ़ाएं',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Ad text
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ड्रिप सिंचाई प्रणाली',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'हमारी स्वचालित ड्रिप सिंचाई प्रणाली से 60% तक पानी की बचत करें और अपनी फसल की पैदावार 40% तक बढ़ाएं।',
                        ),
                      ],
                    ),
                  ),
                  // Countdown and CTA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '0:05',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: onPressed,
                            child: const Text('रिवॉर्ड पाएं'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              // Close button only visible after countdown
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onClosed != null) {
                      onClosed!();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNativeAd() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ad label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.yellow[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Text(
              'विज्ञापन',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Ad content
          InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ad icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Colors.green,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Ad details
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'जैविक खाद - फसल का सुपरफूड',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'हमारी प्रमाणित जैविक खाद से फसल की गुणवत्ता और मात्रा में वृद्धि करें',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₹800/बोरी - अभी ऑर्डर करें',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Call to action
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 12),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(100, 32),
                ),
                onPressed: onPressed,
                child: const Text('अधिक जानकारी'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Show a demo interstitial ad dialog
  static Future<void> showInterstitial(BuildContext context, {
    VoidCallback? onPressed,
    VoidCallback? onClosed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TestAdDisplay(
        adType: AdType.interstitial,
        onPressed: onPressed,
        onClosed: onClosed,
      ),
    );
  }
  
  /// Show a demo rewarded ad dialog
  static Future<void> showRewarded(BuildContext context, {
    VoidCallback? onPressed,
    VoidCallback? onClosed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TestAdDisplay(
        adType: AdType.rewarded,
        onPressed: onPressed,
        onClosed: onClosed,
      ),
    );
  }
}

/// Types of ads available for demonstration
enum AdType {
  banner,
  interstitial,
  rewarded,
  native,
}