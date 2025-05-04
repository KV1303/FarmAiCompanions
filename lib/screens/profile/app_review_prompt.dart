import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/ad_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A dialog to prompt users to rate the app with incentive options
class AppReviewPrompt extends StatelessWidget {
  static const String _hasRatedKey = 'user_has_rated_app';
  static const String _lastPromptDateKey = 'last_rating_prompt_date';
  static const int _minimumDaysBetweenPrompts = 30;
  
  const AppReviewPrompt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and icon
            const Icon(
              Icons.star,
              color: AppColors.accentColor,
              size: 64,
            ),
            const SizedBox(height: 12),
            const Text(
              'आपको FarmAssist AI कैसा लगा?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Description
            const Text(
              'हमें अपने अनुभव के बारे में बताएं और हमें अपनी सेवा को बेहतर बनाने में मदद करें। एक अच्छी रेटिंग हमें मदद करती है!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Options for the user
            ElevatedButton.icon(
              icon: const Icon(Icons.rate_review),
              label: const Text('अभी रेटिंग दें'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _handleRateNow(context),
            ),
            const SizedBox(height: 12),
            
            // Reward option
            if (!adProvider.isPremium)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('विज्ञापन देखें और 1 दिन का प्रीमियम पाएं'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _handleWatchAdForReward(context),
              ),
            const SizedBox(height: 12),
            
            // Remind later button
            TextButton(
              child: const Text('बाद में याद दिलाएं'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            
            // Never ask button
            TextButton(
              child: const Text(
                'फिर कभी न पूछें',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => _handleNeverAskAgain(context),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _handleRateNow(BuildContext context) async {
    // Mark that the user has rated the app
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, true);
    
    // In a real app, you would use a package like url_launcher to open the App Store or Play Store
    // For simulation:
    Navigator.of(context).pop(true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ऐप स्टोर खुला'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  Future<void> _handleWatchAdForReward(BuildContext context) async {
    // Close the dialog first
    Navigator.of(context).pop(false);
    
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    // Show rewarded ad and grant premium for 1 day on success
    adProvider.showRewardedAd(onRewarded: (_) {
      _grantOneDayPremium(context);
    });
  }
  
  Future<void> _grantOneDayPremium(BuildContext context) async {
    // Mark that the user has rated the app
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, true);
    
    // In a real app, set premium for one day
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    await adProvider.setPremiumStatus(true);
    
    // Set a timer to remove premium after one day
    // This is a simplified implementation
    // In a real app, you would store the premium end date and check it on app start
    Future.delayed(const Duration(days: 1), () {
      if (adProvider.isPremium) {
        adProvider.setPremiumStatus(false);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('आपको 1 दिन का मुफ्त प्रीमियम मिल गया है!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  Future<void> _handleNeverAskAgain(BuildContext context) async {
    // Mark that the user doesn't want to be asked again
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, true);
    
    Navigator.of(context).pop(false);
  }
  
  /// Check if we should show the review prompt
  static Future<bool> shouldShowReviewPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user has already rated or opted out
    final hasRated = prefs.getBool(_hasRatedKey) ?? false;
    if (hasRated) {
      return false;
    }
    
    // Check when we last showed the prompt
    final lastPromptDateStr = prefs.getString(_lastPromptDateKey);
    if (lastPromptDateStr != null) {
      final lastPromptDate = DateTime.parse(lastPromptDateStr);
      final daysSinceLastPrompt = DateTime.now().difference(lastPromptDate).inDays;
      
      // Don't show if we've prompted recently
      if (daysSinceLastPrompt < _minimumDaysBetweenPrompts) {
        return false;
      }
    }
    
    // Update the last prompt date
    await prefs.setString(_lastPromptDateKey, DateTime.now().toIso8601String());
    
    return true;
  }
  
  /// Show the review prompt dialog if conditions are met
  static Future<void> showIfNeeded(BuildContext context) async {
    if (await shouldShowReviewPrompt()) {
      // Show after a slight delay
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AppReviewPrompt(),
          );
        }
      });
    }
  }
}