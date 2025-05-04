import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../web_view_screen.dart';
import '../field_monitoring/field_dashboard_screen.dart';
import '../disease_detection/disease_detection_screen.dart';
import '../market_prices/market_prices_screen.dart';
import '../weather/weather_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Base URL to your web app API
  final String apiBaseUrl = 'http://localhost:5003'; // Will be replaced with actual deployment URL

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // WebView configuration for main content
  Widget _buildWebContent(String initialPath) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id ?? 'anonymous';
    final fullUrl = '$apiBaseUrl$initialPath?user_id=$userId';
    
    return WebViewScreen(
      initialUrl: fullUrl,
      title: 'FarmAssistAI',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Main WebView Screen for homepage content
          _buildWebContent('/'),
          
          // Field Monitoring Screen (could be converted to WebView or kept native)
          const FieldDashboardScreen(),
          
          // Disease Detection (likely needs native camera access)
          const DiseaseDetectionScreen(),
          
          // Market Prices Screen
          const MarketPricesScreen(),
          
          // Profile Screen
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'होम',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.landscape),
            label: 'खेत',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'रोग पहचान',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'बाज़ार',
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