import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/test_ad_display.dart';

/// A screen to demonstrate all ad types for testing purposes
class AdDemoScreen extends StatefulWidget {
  const AdDemoScreen({Key? key}) : super(key: key);

  @override
  State<AdDemoScreen> createState() => _AdDemoScreenState();
}

class _AdDemoScreenState extends State<AdDemoScreen> {
  int _rewardPoints = 0;
  bool _rewardUnlocked = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('विज्ञापन डेमो'),
        actions: [
          // Points indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_rewardPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction text
              const Text(
                'विज्ञापन प्रकारों का डेमो',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'इस स्क्रीन पर आप विभिन्न प्रकार के विज्ञापनों का डेमो देख सकते हैं। ये सभी विज्ञापन परीक्षण के उद्देश्य से हैं और वास्तविक विज्ञापन नहीं हैं।',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              // Premium offer
              if (_rewardUnlocked)
                _buildPremiumFeatureCard()
              else
                _buildLockedFeatureCard(),
                
              const SizedBox(height: 32),
              
              // Banner ad example
              _buildSectionHeader('बैनर विज्ञापन'),
              const SizedBox(height: 8),
              TestAdDisplay(
                adType: AdType.banner,
                onPressed: () => _showAdClickedMessage('बैनर'),
              ),
              const SizedBox(height: 24),
              
              // Native ad example
              _buildSectionHeader('नेटिव विज्ञापन'),
              const Text(
                'ये विज्ञापन कंटेंट के साथ घुले-मिले दिखते हैं',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TestAdDisplay(
                adType: AdType.native,
                onPressed: () => _showAdClickedMessage('नेटिव'),
              ),
              const SizedBox(height: 24),
              
              // Interstitial ad button
              _buildSectionHeader('इंटरस्टिशियल विज्ञापन'),
              const Text(
                'ये पूरी स्क्रीन को कवर करने वाले विज्ञापन हैं',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.fullscreen),
                label: const Text('इंटरस्टिशियल विज्ञापन दिखाएं'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _showInterstitialAd,
              ),
              const SizedBox(height: 24),
              
              // Rewarded ad button
              _buildSectionHeader('रिवॉर्ड विज्ञापन'),
              const Text(
                'इन विज्ञापनों को देखकर इनाम पाएं',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.card_giftcard),
                label: const Text('रिवॉर्ड विज्ञापन देखें'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                onPressed: _showRewardedAd,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      // Banner ad at bottom
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TestAdDisplay(
            adType: AdType.banner,
            onPressed: () => _showAdClickedMessage('बैनर'),
          ),
          BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'होम',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'खोज',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'प्रोफाइल',
              ),
            ],
            currentIndex: 0,
            onTap: (_) {},
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildLockedFeatureCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  'प्रीमियम सुविधा',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '10',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'रिवॉर्ड विज्ञापन देखकर 10 अंक इकट्ठा करें और इस प्रीमियम सुविधा को अनलॉक करें!',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.card_giftcard),
              label: const Text('विज्ञापन देखें और अनलॉक करें'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
              onPressed: _showRewardedAd,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPremiumFeatureCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_open, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'प्रीमियम सुविधा अनलॉक!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'अनलॉक',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'बधाई हो! आपने रिवॉर्ड विज्ञापन देखकर इस प्रीमियम सुविधा को अनलॉक कर लिया है।',
            ),
            const SizedBox(height: 16),
            const Text(
              '🌱 हमारे विशेषज्ञों द्वारा तैयार किया गया यह विशेष मार्गदर्शन आपकी फसल की उपज बढ़ाने में मदद करेगा।',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• मिट्टी में नमी बनाए रखने के लिए मल्चिंग का उपयोग करें।\n'
              '• सही समय पर सिंचाई करें, अधिक पानी न डालें।\n'
              '• जैविक खाद का उपयोग करें, मिट्टी की उर्वरता बढ़ाएं।',
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAdClickedMessage(String adType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$adType विज्ञापन पर क्लिक किया गया'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  void _showInterstitialAd() {
    TestAdDisplay.showInterstitial(
      context,
      onPressed: () {
        Navigator.of(context).pop();
        _showAdClickedMessage('इंटरस्टिशियल');
      },
      onClosed: () {
        _showAdClosedMessage('इंटरस्टिशियल');
      },
    );
  }
  
  void _showRewardedAd() {
    TestAdDisplay.showRewarded(
      context,
      onPressed: () {
        Navigator.of(context).pop();
        
        // Add reward points
        setState(() {
          _rewardPoints += 5;
          
          if (_rewardPoints >= 10) {
            _rewardUnlocked = true;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('आपको 5 अंक मिले!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onClosed: () {
        _showAdClosedMessage('रिवॉर्ड');
      },
    );
  }
  
  void _showAdClosedMessage(String adType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$adType विज्ञापन बंद किया गया'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}