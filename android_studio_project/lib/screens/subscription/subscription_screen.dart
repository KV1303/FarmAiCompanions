import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/ad_provider.dart';

/// A screen that allows users to subscribe to premium to remove ads
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    final isInTrial = adProvider.isInTrial;
    final daysLeft = adProvider.daysLeftInTrial;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('प्रीमियम सदस्यता'),
        elevation: 0,
        backgroundColor: AppColors.premium,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with premium badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                color: AppColors.premium,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      size: 48,
                      color: AppColors.premium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'FarmAssist AI प्रीमियम',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'विज्ञापन मुक्त अनुभव',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            
            // Trial status section
            if (isInTrial)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.premium.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.premium.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'आपका प्रीमियम परीक्षण सक्रिय है',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.premium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'आपका परीक्षण $daysLeft दिनों में समाप्त हो जाएगा',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'अभी सदस्यता लें और अपने प्रीमियम लाभों को जारी रखें',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Premium features list
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'प्रीमियम लाभ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: Icons.block,
                    title: 'सभी विज्ञापन हटा दिए गए',
                    description: 'बिना किसी रुकावट के बेहतर अनुभव प्राप्त करें',
                  ),
                  _buildFeatureItem(
                    icon: Icons.article,
                    title: 'विशेष कृषि मार्गदर्शन',
                    description: 'उन्नत फसल प्रबंधन सिफारिशें और हमारे विशेषज्ञों से सलाह',
                  ),
                  _buildFeatureItem(
                    icon: Icons.priority_high,
                    title: 'प्राथमिकता सहायता',
                    description: 'कृषि प्रश्नों के लिए त्वरित उत्तर और समर्थन',
                  ),
                  _buildFeatureItem(
                    icon: Icons.downloading,
                    title: 'रिपोर्ट डाउनलोड करें',
                    description: 'अपनी कृषि रिपोर्ट और सिफारिशें डाउनलोड करें',
                  ),
                ],
              ),
            ),
            
            // Subscription plan
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.premium,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Row with plan name and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'वार्षिक योजना',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'सबसे लोकप्रिय',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.premium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text(
                              '₹99/वर्ष',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'केवल ₹8.25/माह',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'विज्ञापन-मुक्त अनुभव + सभी प्रीमियम सुविधाएँ',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Payment button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _processPayment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.premium,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'अभी सदस्यता लें',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Terms and conditions
                    const Text(
                      '7 दिनों के निःशुल्क परीक्षण के बाद ₹99/वर्ष',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // Security note
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Text(
                'सुरक्षित भुगतान गेटवे द्वारा संचालित',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.premium.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.premium,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _processPayment(BuildContext context) {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('भुगतान की प्रक्रिया चल रही है...'),
            ],
          ),
        ),
      ),
    );
    
    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Update subscription status
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      adProvider.setPremiumStatus(true);
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('सदस्यता सफल!'),
          content: const Text(
            'आपकी प्रीमियम सदस्यता सफलतापूर्वक सक्रिय हो गई है। अब आप विज्ञापन-मुक्त अनुभव और सभी प्रीमियम सुविधाओं का आनंद ले सकते हैं।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('ठीक है'),
            ),
          ],
        ),
      );
    });
  }
}