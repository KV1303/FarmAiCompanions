import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/ad_service.dart';
import 'dashboard_screen.dart';
import 'market_prices_screen.dart';
import 'disease_detection_screen.dart';
import 'farm_management_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  DateTime? _lastAdShowTime;
  static const int interstitialCooldownSeconds = 30;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const MarketPricesScreen(),
      const DiseaseDetectionScreen(),
      const FarmManagementScreen(),
      const ProfileScreen(),
    ];
  }

  // Check if enough time has passed since the last ad was shown
  bool _shouldShowAd() {
    if (_lastAdShowTime == null) return true;
    final difference = DateTime.now().difference(_lastAdShowTime!);
    return difference.inSeconds >= interstitialCooldownSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          // Show interstitial ad when changing tabs, if we're not on a cooldown
          if (_currentIndex != index && _shouldShowAd()) {
            final adService = Provider.of<AdService>(context, listen: false);
            final wasAdShown = await adService.showInterstitialAd(context);
            
            if (wasAdShown) {
              setState(() {
                _lastAdShowTime = DateTime.now();
              });
            }
          }
          
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'डैशबोर्ड',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'मार्केट',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bug_report),
            label: 'बीमारियां',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'खेत',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'प्रोफाइल',
          ),
        ],
      ),
    );
  }
}

// Temporary implementation of FarmManagementScreen for compilation
class FarmManagementScreen extends StatelessWidget {
  const FarmManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('खेत प्रबंधन'),
      ),
      body: const Center(
        child: Text('खेत प्रबंधन सामग्री'),
      ),
    );
  }
}

// Temporary implementation of ProfileScreen for compilation
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('प्रोफाइल'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('प्रोफाइल सामग्री'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authService.logout();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('लॉगआउट त्रुटि: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('लॉगआउट'),
            ),
          ],
        ),
      ),
    );
  }
}