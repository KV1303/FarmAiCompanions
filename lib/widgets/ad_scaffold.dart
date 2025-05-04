import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';
import 'test_ad_display.dart';

/// A scaffold that automatically includes banner ads at top and/or bottom
/// depending on the user's subscription status.
class AdScaffold extends StatelessWidget {
  final String screenName;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final FloatingActionButton? floatingActionButton;
  final bool showTopBanner;
  final bool showBottomBanner;
  
  const AdScaffold({
    Key? key,
    required this.screenName,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showTopBanner = true,
    this.showBottomBanner = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          // Show top banner ad for non-premium users if enabled
          if (showTopBanner && !adProvider.isPremium)
            TestAdDisplay(
              adType: AdType.banner,
              onPressed: () {},
            ),
            
          // Main content area
          Expanded(
            child: body,
          ),
          
          // Show bottom banner ad for non-premium users if enabled
          if (showBottomBanner && !adProvider.isPremium)
            TestAdDisplay(
              adType: AdType.banner,
              onPressed: () {},
            ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}