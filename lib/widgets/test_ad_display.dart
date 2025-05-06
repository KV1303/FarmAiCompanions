import 'package:flutter/material.dart';

/// Types of ads that can be displayed
enum AdType { banner, interstitial, rewarded, native }

/// A widget that displays test ads for demo purposes
/// In production, this would be replaced with actual AdMob implementations
class TestAdDisplay extends StatelessWidget {
  final AdType adType;
  final VoidCallback? onPressed;
  final String? customTitle;
  final String? customDescription;
  
  const TestAdDisplay({
    Key? key,
    required this.adType,
    this.onPressed,
    this.customTitle,
    this.customDescription,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    switch (adType) {
      case AdType.banner:
        return _buildBannerAd(context);
      case AdType.native:
        return _buildNativeAd(context);
      default:
        return const SizedBox.shrink(); // Interstitial and rewarded are shown as dialogs
    }
  }
  
  /// Builds a test banner ad
  Widget _buildBannerAd(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.grey[200],
      child: InkWell(
        onTap: onPressed,
        child: Stack(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.eco, color: Colors.green),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        customTitle ?? 'कृषि इनपुट्स पर विशेष छूट',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        customDescription ?? 'उन्नत खेती अपनाएं, उत्पादन बढ़ाएं',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'अभी देखें',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 2,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  'विज्ञापन',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds a test native ad
  Widget _buildNativeAd(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.landscape,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            customTitle ?? 'स्वदेशी जैविक उर्वरक',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            customDescription ?? 'फसलों की उत्पादकता और गुणवत्ता में वृद्धि करें',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹850/बोरी',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'विज्ञापन',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'अधिक जानकारी',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Shows an interstitial ad dialog
  static void showInterstitial(BuildContext context, {VoidCallback? onPressed}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'विज्ञापन',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    'FarmAssist AI',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onPressed != null) onPressed();
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              color: Colors.green[50],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 60,
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'स्मार्ट कृषि उपकरण',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'समय और श्रम की बचत करें',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'किसानों के लिए विशेष ऑफर',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'अधिक कम श्रम में अधिक उपज पाने के लिए अब हमारे आधुनिक कृषि उपकरण उपलब्ध हैं। 15% की विशेष छूट पाएं!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onPressed != null) onPressed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'अभी खरीदें',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Shows a rewarded ad dialog
  static void showRewarded(BuildContext context, {VoidCallback? onPressed}) {
    bool isWatched = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Simulate ad progress timer
          if (!isWatched) {
            Future.delayed(const Duration(seconds: 5), () {
              if (context.mounted) {
                setState(() {
                  isWatched = true;
                });
              }
            });
          }
          
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'रिवॉर्ड विज्ञापन',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'FarmAssist AI',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onPressed != null) onPressed();
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.purple[50],
                  child: Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        color: Colors.purple[700],
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'विज्ञापन पूरा देखने के बाद प्रीमियम सामग्री एक्सेस करें!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 200,
                  color: Colors.blue[50],
                  child: Stack(
                    children: [
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop,
                              size: 60,
                              color: Colors.blue,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'स्वचालित सिंचाई प्रणाली',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'पानी की बचत, फसलों की सुरक्षा',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isWatched)
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '0:05',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'स्वचालित ड्रिप सिंचाई',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'हमारे स्मार्ट सिंचाई सिस्टम से आप 30% कम पानी का उपयोग करते हुए अपनी फसलों की पैदावार बढ़ा सकते हैं।',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isWatched
                            ? () {
                                Navigator.of(context).pop();
                                if (onPressed != null) onPressed();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text(
                          isWatched ? 'रिवॉर्ड प्राप्त करें' : 'विज्ञापन देखें जा रहा है...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}