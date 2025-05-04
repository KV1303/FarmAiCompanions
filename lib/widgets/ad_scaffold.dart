import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';
import '../services/ad_service.dart';
import 'adaptive_banner_ad.dart';

/// A scaffold that automatically includes banner ads at the top or bottom
/// based on ad settings and screen configuration
class AdScaffold extends StatefulWidget {
  final String screenName;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  
  const AdScaffold({
    Key? key,
    required this.screenName,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  }) : super(key: key);

  @override
  State<AdScaffold> createState() => _AdScaffoldState();
}

class _AdScaffoldState extends State<AdScaffold> {
  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    final showBanner = AdService.shouldShowBannerInScreen(widget.screenName) && !adProvider.isPremium;
    final showAtTop = AdService.showBannerAtTop;
    
    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: showBanner && !showAtTop 
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AdaptiveBannerAd(),
                if (widget.bottomNavigationBar != null) widget.bottomNavigationBar!,
              ],
            )
          : widget.bottomNavigationBar,
      body: Column(
        children: [
          // Show banner at top if configured that way
          if (showBanner && showAtTop) 
            const AdaptiveBannerAd(isTopBanner: true),
          
          // Main content
          Expanded(
            child: widget.body,
          ),
        ],
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    // Track page view for ad frequency capping
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      adProvider.trackPageView();
    });
  }
  
  @override
  void dispose() {
    // Show interstitial when leaving screen if appropriate
    if (AdService.shouldShowInterstitialAfterScreen(widget.screenName)) {
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      adProvider.showInterstitialAd();
    }
    super.dispose();
  }
}