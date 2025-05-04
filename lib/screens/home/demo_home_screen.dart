import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/ad_provider.dart';
import '../../widgets/test_ad_display.dart';
import '../../widgets/ad_scaffold.dart';
import '../../screens/profile/app_review_prompt.dart';
import '../../screens/subscription/subscription_screen.dart';

class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({Key? key}) : super(key: key);

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _pageViewCount = 0;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Show app rating prompt after interacting with multiple sections
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _maybeShowRatingDialog();
        }
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    
    return AdScaffold(
      screenName: 'demo_home_screen',
      appBar: AppBar(
        title: const Text('FarmAssist AI'),
        actions: [
          // Subscription button
          if (!adProvider.isPremium)
            IconButton(
              icon: const Icon(Icons.workspace_premium),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'होम'),
            Tab(text: 'मौसम'),
            Tab(text: 'बाज़ार'),
            Tab(text: 'बीमारी'),
            Tab(text: 'चैट'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner ad at top (if enabled in AdService)
          if (!adProvider.isPremium)
            TestAdDisplay(
              adType: AdType.banner,
              onPressed: () => _showMessage('बैनर विज्ञापन पर क्लिक किया गया'),
            ),
            
          // Main content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(),
                _buildWeatherTab(),
                _buildMarketTab(),
                _buildDiseaseTab(),
                _buildChatTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageViewCount++;
            
            // Show interstitial ad occasionally when switching tabs
            if (_pageViewCount % 4 == 0 && !adProvider.isPremium) {
              TestAdDisplay.showInterstitial(
                context,
                onPressed: () => Navigator.of(context).pop(),
              );
            }
          });
        },
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
      ),
    );
  }
  
  // Tab content builders
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            
            // Weather overview card
            _buildInfoCard(
              title: 'आज का मौसम',
              icon: Icons.wb_sunny,
              color: Colors.orange,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('पंचकुला, हरियाणा', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('35°C | आंशिक बादल | वर्षा की 20% संभावना'),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      _showMessage('मौसम विवरण दिखाया गया');
                      _tabController.animateTo(1);
                    },
                    child: const Text('पूर्ण पूर्वानुमान'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Fields section
            const Text(
              'मेरे खेत',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Field cards
            _buildFieldCard(
              name: 'गन्ना का खेत',
              location: 'जींद',
              cropType: 'गन्ना',
              image: Icons.grass,
              onTap: () => _showFieldDetails(),
            ),
            const SizedBox(height: 12),
            
            // Insert a native ad
            Provider.of<AdProvider>(context).isPremium
                ? const SizedBox.shrink()
                : TestAdDisplay(
                    adType: AdType.native,
                    onPressed: () => _showMessage('नेटिव विज्ञापन पर क्लिक किया गया'),
                  ),
            const SizedBox(height: 12),
            
            _buildFieldCard(
              name: 'सरसों का खेत',
              location: 'पंचकुला',
              cropType: 'सरसों',
              image: Icons.eco,
              onTap: () => _showFieldDetails(),
            ),
            
            const SizedBox(height: 24),
            
            // Market prices preview
            const Text(
              'बाज़ार मूल्य अपडेट',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            _buildMarketPriceCard(),
            
            const SizedBox(height: 24),
            
            // Action buttons
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildActionButton(
                  icon: Icons.water_drop,
                  title: 'सिंचाई सलाह',
                  color: Colors.blue,
                  onTap: () => _showIrrigationAdvice(),
                ),
                _buildActionButton(
                  icon: Icons.local_florist,
                  title: 'फसल देखभाल',
                  color: Colors.green,
                  onTap: () => _showPremiumContentPrompt(),
                ),
                _buildActionButton(
                  icon: Icons.bug_report,
                  title: 'कीट निगरानी',
                  color: Colors.orange,
                  onTap: () => _tabController.animateTo(3),
                ),
                _buildActionButton(
                  icon: Icons.forum,
                  title: 'कृषि सलाहकार',
                  color: Colors.purple,
                  onTap: () => _tabController.animateTo(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherTab() {
    return const Center(
      child: Text('मौसम टैब - यहां मौसम जानकारी दिखाई जाएगी'),
    );
  }

  Widget _buildMarketTab() {
    return const Center(
      child: Text('बाज़ार टैब - यहां बाज़ार मूल्य दिखाए जाएंगे'),
    );
  }

  Widget _buildDiseaseTab() {
    return const Center(
      child: Text('बीमारी टैब - यहां बीमारी निदान जानकारी दिखाई जाएगी'),
    );
  }

  Widget _buildChatTab() {
    return const Center(
      child: Text('चैट टैब - यहां AI चैटबॉट दिखाया जाएगा'),
    );
  }
  
  // UI Components
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryColor,
              child: const Text(
                'RS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'नमस्ते, राजेश सिंह',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'आपकी फसलें अच्छी स्थिति में हैं',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
  
  Widget _buildFieldCard({
    required String name,
    required String location,
    required String cropType,
    required IconData image,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  image,
                  size: 36,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$cropType | $location',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.water_drop, size: 14, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('सिंचाई की आवश्यकता', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMarketPriceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('फसल', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('मूल्य (क्विंटल)', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('परिवर्तन', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            _buildMarketPriceRow('गेहूं', '₹2,400', '+₹120', true),
            _buildMarketPriceRow('चावल', '₹3,800', '-₹50', false),
            _buildMarketPriceRow('गन्ना', '₹350', '+₹10', true),
            _buildMarketPriceRow('सरसों', '₹6,200', '+₹280', true),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                _showMessage('बाज़ार मूल्य विवरण दिखाया गया');
                _tabController.animateTo(2);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('सभी मूल्य देखें'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMarketPriceRow(String crop, String price, String change, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(crop),
          Text(price),
          Text(
            change,
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Actions and interactions
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _showFieldDetails() {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    // Show interstitial ad before showing field details (for non-premium users)
    if (!adProvider.isPremium) {
      TestAdDisplay.showInterstitial(
        context,
        onPressed: () {
          Navigator.of(context).pop();
          _showMessage('खेत का विस्तृत विवरण दिखाया जाएगा');
        },
      );
    } else {
      _showMessage('खेत का विस्तृत विवरण दिखाया जाएगा');
    }
  }
  
  void _showIrrigationAdvice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('सिंचाई सलाह'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('अगले 5 दिनों के लिए सिंचाई की अनुशंसा:'),
            SizedBox(height: 8),
            Text('• आज: सिंचाई करें (15-20 मिमी)'),
            Text('• 6 मई: सिंचाई न करें (संभावित वर्षा)'),
            Text('• 7 मई: सिंचाई न करें'),
            Text('• 8 मई: हल्की सिंचाई (10 मिमी)'),
            Text('• 9 मई: जरूरत के अनुसार'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('बंद करें'),
          ),
        ],
      ),
    );
  }
  
  void _showPremiumContentPrompt() {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    if (adProvider.isPremium) {
      // Show premium content directly for premium users
      _showMessage('प्रीमियम फसल देखभाल सामग्री दिखाई जाएगी');
    } else {
      // Show rewarded ad option for non-premium users
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('प्रीमियम सामग्री'),
          content: const Text(
            'यह सामग्री केवल प्रीमियम सदस्यों के लिए उपलब्ध है। आप एक विज्ञापन देखकर इसे अनलॉक कर सकते हैं या सदस्यता ले सकते हैं।'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('बाद में'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showRewardedAdForContent();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: const Text('विज्ञापन देखें'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                );
              },
              child: const Text('सदस्यता लें'),
            ),
          ],
        ),
      );
    }
  }
  
  void _showRewardedAdForContent() {
    TestAdDisplay.showRewarded(
      context,
      onPressed: () {
        Navigator.of(context).pop();
        _showMessage('आपको फसल देखभाल सामग्री मिल गई है!');
        
        // Show the unlocked content
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('फसल देखभाल मार्गदर्शिका'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'सरसों की फसल के लिए अप्रैल-मई के महीने में ध्यान देने योग्य बातें:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• फसल में किसी भी कीट के प्रकोप पर नज़र रखें'),
                Text('• तापमान बढ़ने के साथ सिंचाई का प्रबंधन सावधानी से करें'),
                Text('• फसल की कटाई के बाद मिट्टी की जांच कराएं'),
                Text('• अगली फसल के लिए खेत तैयार करने की योजना बनाएं'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('बंद करें'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // App rating dialog related
  void _maybeShowRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ऐप रेटिंग'),
        content: const Text(
          'इस डेमो में, विभिन्न स्थानों पर ऐप इस्तेमाल करने के बाद रेटिंग डायलॉग दिखाया जाएगा। रेटिंग देने के लिए एक रिवॉर्ड विज्ञापन का उपयोग किया जा सकता है।'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('बाद में'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRatingDialogWithReward();
            },
            child: const Text('रेटिंग डायलॉग दिखाएं'),
          ),
        ],
      ),
    );
  }
  
  void _showRatingDialogWithReward() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'FarmAssist AI को रेट करें',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'आपका फीडबैक हमारे लिए महत्वपूर्ण है। एक छोटा विज्ञापन देखकर 1 दिन की प्रीमियम सदस्यता पाएं!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 36,
                    color: index < 4 ? Colors.amber : Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('बाद में'),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('विज्ञापन देखें'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showRewardedAdForRating();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showRewardedAdForRating() {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    TestAdDisplay.showRewarded(
      context,
      onPressed: () {
        Navigator.of(context).pop();
        
        // Temporarily set premium status for demo
        adProvider.setPremiumStatus(true);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('आपको 1 दिन की प्रीमियम सदस्यता मिल गई है!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset premium status after 1 minute (for demo purposes)
        Future.delayed(const Duration(minutes: 1), () {
          if (mounted) {
            adProvider.setPremiumStatus(false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('डेमो: प्रीमियम सदस्यता समाप्त हो गई है।'),
              ),
            );
          }
        });
      },
    );
  }
}