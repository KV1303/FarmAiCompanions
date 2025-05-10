import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'providers/ad_provider.dart';
import 'screens/test/ad_demo_screen.dart';
import 'screens/home/demo_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdProvider()),
      ],
      child: MaterialApp(
        title: 'FarmAssist AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryColor,
            primary: AppColors.primaryColor,
            secondary: AppColors.accentColor,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        home: const DemoLauncherScreen(),
      ),
    );
  }
}

/// A simple launcher screen to navigate between different demo screens
class DemoLauncherScreen extends StatelessWidget {
  const DemoLauncherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmAssist AI - डेमो'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'विज्ञापन प्रदर्शन डेमो',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'नीचे दिए गए विकल्पों में से एक का चयन करें:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            _buildDemoCard(
              context,
              title: 'सभी विज्ञापन प्रकारों का डेमो',
              description: 'बैनर, इंटरस्टिशियल, रिवॉर्ड और नेटिव विज्ञापनों का प्रदर्शन',
              icon: Icons.view_carousel,
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const AdDemoScreen()),
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildDemoCard(
              context,
              title: 'होम स्क्रीन डेमो',
              description: 'वास्तविक ऐप होम स्क्रीन में विज्ञापन एकीकरण',
              icon: Icons.home,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DemoHomeScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDemoCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppColors.primaryColor,
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
                        fontSize: 18,
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
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}