import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';
import 'rewarded_ad_button.dart';

class PremiumContentDialog extends StatelessWidget {
  final String title;
  final String description;
  final Widget? icon;
  final VoidCallback? onSubscribe;
  final VoidCallback onWatchAd;
  final String watchAdButtonText;
  final String subscribeButtonText;
  
  const PremiumContentDialog({
    Key? key,
    required this.title,
    required this.description,
    this.icon,
    this.onSubscribe,
    required this.onWatchAd,
    this.watchAdButtonText = 'विज्ञापन देखें',
    this.subscribeButtonText = 'सदस्यता लें',
  }) : super(key: key);

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
            // Premium content icon
            icon ?? const Icon(
              Icons.workspace_premium,
              color: Colors.amber,
              size: 60,
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show the rewarded ad button only for non-premium users
                if (!adProvider.isPremium)
                  RewardedAdButton(
                    text: watchAdButtonText,
                    icon: Icons.play_circle_outline,
                    color: Colors.amber,
                    onRewarded: () {
                      Navigator.of(context).pop();
                      onWatchAd();
                    },
                    rewardDescription: title,
                  ),
                
                if (!adProvider.isPremium) 
                  const SizedBox(height: 12),
                
                // Subscribe button
                if (onSubscribe != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.workspace_premium),
                    label: Text(subscribeButtonText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onSubscribe!();
                    },
                  ),
                
                const SizedBox(height: 8),
                
                // Cancel button
                TextButton(
                  child: const Text('बाद में'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    Widget? icon,
    VoidCallback? onSubscribe,
    required VoidCallback onWatchAd,
    String watchAdButtonText = 'विज्ञापन देखें',
    String subscribeButtonText = 'सदस्यता लें',
  }) {
    return showDialog(
      context: context,
      builder: (context) => PremiumContentDialog(
        title: title,
        description: description,
        icon: icon,
        onSubscribe: onSubscribe,
        onWatchAd: onWatchAd,
        watchAdButtonText: watchAdButtonText,
        subscribeButtonText: subscribeButtonText,
      ),
    );
  }
}