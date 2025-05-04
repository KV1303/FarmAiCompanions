import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/ad_provider.dart';
import '../../widgets/ad_scaffold.dart';
import '../../services/payment_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;
  String _selectedPlan = 'yearly'; // 'monthly' or 'yearly'
  
  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    final isPremium = adProvider.isPremium;
    
    return AdScaffold(
      screenName: 'subscription_screen',
      appBar: AppBar(
        title: const Text('प्रीमियम सदस्यता'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              
              // Premium icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  size: 80,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'FarmAssist AI प्रीमियम',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Description
              const Text(
                'अपनी खेती को अगले स्तर पर ले जाएं, सभी प्रीमियम सुविधाओं का अनलिमिटेड एक्सेस पाएं और बिना विज्ञापनों के सुविधाजनक अनुभव का आनंद लें।',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Features list
              _buildFeatureItem(
                icon: Icons.block,
                title: 'विज्ञापन-मुक्त अनुभव',
                description: 'किसी भी विज्ञापन के बिना बिना रुकावट के ऐप का उपयोग करें',
              ),
              _buildFeatureItem(
                icon: Icons.article,
                title: 'प्रीमियम लेख और गाइड',
                description: 'विशेषज्ञों द्वारा लिखित विशेष सामग्री और गहन विश्लेषण तक पहुंच',
              ),
              _buildFeatureItem(
                icon: Icons.analytics,
                title: 'उन्नत फसल विश्लेषण',
                description: 'अपने खेतों के लिए व्यापक डेटा-संचालित अंतर्दृष्टि और विश्लेषण',
              ),
              _buildFeatureItem(
                icon: Icons.priority_high,
                title: 'प्राथमिकता समर्थन',
                description: 'किसी भी समस्या के समाधान के लिए त्वरित और प्राथमिकता वाली सहायता',
              ),
              const SizedBox(height: 32),
              
              // If already premium
              if (isPremium)
                _buildActivePremiumSection()
              else
                _buildSubscriptionOptions(),
                
              const SizedBox(height: 24),
              
              // Trial info
              if (!isPremium)
                const Text(
                  '7 दिनों का निःशुल्क परीक्षण, किसी भी समय रद्द करें',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              
              const SizedBox(height: 32),
            ],
          ),
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
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivePremiumSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 36,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'प्रीमियम सदस्यता सक्रिय',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'आप पहले से ही सभी प्रीमियम सुविधाओं का आनंद ले रहे हैं',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () {
            // Show subscription management options
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('सदस्यता प्रबंधन'),
                content: const Text(
                  'अपनी सदस्यता को प्रबंधित करने के लिए, कृपया अपने ऐप स्टोर खाते से सदस्यताओं अनुभाग पर जाएं।'
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ठीक है'),
                  ),
                ],
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('सदस्यता प्रबंधित करें'),
        ),
      ],
    );
  }
  
  Widget _buildSubscriptionOptions() {
    return Column(
      children: [
        // Plan selection
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Monthly option
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPlan = 'monthly';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedPlan == 'monthly'
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(
                          'मासिक',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedPlan == 'monthly' ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹59/माह',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedPlan == 'monthly' ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Yearly option
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPlan = 'yearly';
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedPlan == 'yearly'
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(11)),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Text(
                              'वार्षिक',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedPlan == 'yearly' ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹99/वर्ष',
                              style: TextStyle(
                                fontSize: 12,
                                color: _selectedPlan == 'yearly' ? Colors.white70 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Savings badge
                      Positioned(
                        top: -10,
                        right: -5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '80% बचत',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Subscribe button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubscription,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Text(
                  'सदस्यता लें',
                  style: TextStyle(fontSize: 16),
                ),
        ),
        const SizedBox(height: 12),
        
        // Restore purchases button
        TextButton(
          onPressed: _isLoading ? null : _handleRestorePurchases,
          child: const Text('पिछली खरीदारी पुनर्स्थापित करें'),
        ),
      ],
    );
  }
  
  Future<void> _handleSubscription() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final productId = _selectedPlan == 'monthly'
          ? 'monthly_subscription'
          : 'yearly_subscription';
          
      final success = await PaymentService.purchase(productId);
      
      if (success) {
        // Update the premium status
        final adProvider = Provider.of<AdProvider>(context, listen: false);
        await adProvider.setPremiumStatus(true);
        
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog('खरीदारी प्रक्रिया के दौरान एक त्रुटि हुई: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _handleRestorePurchases() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final restored = await PaymentService.restorePurchases();
      
      if (restored) {
        // Update the premium status
        final adProvider = Provider.of<AdProvider>(context, listen: false);
        await adProvider.setPremiumStatus(true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('पिछली खरीदारी सफलतापूर्वक पुनर्स्थापित की गई'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('कोई सक्रिय सदस्यता नहीं मिली'),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('खरीदारी पुनर्स्थापित करने के दौरान एक त्रुटि हुई: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('सदस्यता सफल!'),
        content: const Text(
          'आपकी प्रीमियम सदस्यता सफलतापूर्वक सक्रिय हो गई है। अब आप सभी प्रीमियम सुविधाओं का आनंद ले सकते हैं!'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('ठीक है'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('त्रुटि'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ठीक है'),
          ),
        ],
      ),
    );
  }
}