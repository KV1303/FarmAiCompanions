import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/ad_provider.dart';
import '../../widgets/test_ad_display.dart';

/// A screen that prompts users to review the app with an incentive
/// through a rewarded ad.
class AppReviewPrompt extends StatelessWidget {
  final VoidCallback? onComplete;
  
  const AppReviewPrompt({Key? key, this.onComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              'आपका फीडबैक हमारे लिए महत्वपूर्ण है। क्या आप हमारी ऐप को रेट करेंगे?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'एक छोटा विज्ञापन देखकर 1 दिन की प्रीमियम सदस्यता पाएं!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.premium,
                fontWeight: FontWeight.bold,
              ),
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
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onComplete != null) onComplete!();
                  },
                  child: const Text('बाद में'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('विज्ञापन देखें'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.premium,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showRewardedAdForRating(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showRewardedAdForRating(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    TestAdDisplay.showRewarded(
      context,
      onPressed: () {
        // Grant 1-day trial premium for watching the ad
        adProvider.startFreeTrial(1);
        
        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('आपको 1 दिन की प्रीमियम सदस्यता मिल गई है!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        if (onComplete != null) onComplete!();
      },
    );
  }
}