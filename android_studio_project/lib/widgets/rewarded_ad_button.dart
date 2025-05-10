import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/ad_provider.dart';

class RewardedAdButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onRewarded;
  final String rewardDescription;

  const RewardedAdButton({
    Key? key,
    required this.text,
    this.icon,
    this.color,
    this.onRewarded,
    this.rewardDescription = 'प्रीमियम सुविधा',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    
    // Premium users don't need to watch ads
    if (adProvider.isPremium && onRewarded != null) {
      return ElevatedButton.icon(
        icon: Icon(icon ?? Icons.lock_open),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed: onRewarded,
      );
    }

    return ElevatedButton.icon(
      icon: Icon(icon ?? Icons.play_circle_outline),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.amber,
        foregroundColor: Colors.black87,
      ),
      onPressed: () => _showRewardedAd(context),
    );
  }

  Future<void> _showRewardedAd(BuildContext context) async {
    // Show a confirmation dialog before showing the ad
    final shouldShow = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('विज्ञापन देखें'),
        content: Text('$rewardDescription का उपयोग करने के लिए एक छोटा विज्ञापन देखें।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('रद्द करें'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('देखें'),
          ),
        ],
      ),
    );

    if (shouldShow != true) return;

    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Show the ad
    final adShown = await adProvider.showRewardedAd(
      onRewarded: (RewardItem reward) {
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        
        // Execute reward callback
        if (onRewarded != null) {
          onRewarded!();
        }
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('आपको $rewardDescription मिल गया है!'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );

    // Close loading dialog if ad failed to show
    if (!adShown) {
      Navigator.of(context, rootNavigator: true).pop();
      
      // Fall back to giving the reward anyway if ad fails to load
      if (onRewarded != null) {
        onRewarded!();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('आपको बिना विज्ञापन के $rewardDescription मिल गया है'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('विज्ञापन लोड नहीं हो सका। कृपया बाद में पुनः प्रयास करें।'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}