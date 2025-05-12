import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/service_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

// API base URL for development/production
const String apiBaseUrl = 'http://localhost:5004'; // Change this for production

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize mobile ads SDK
  await MobileAds.instance.initialize();
  
  // Initialize Firebase with proper options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiceProvider(
      apiBaseUrl: apiBaseUrl,
      testAdsMode: false, // Set to true for test ads only
      child: StreamProvider<User?>.value(
        value: FirebaseAuth.instance.authStateChanges(),
        initialData: null,
        child: MaterialApp(
          title: 'फार्म असिस्ट AI',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            useMaterial3: true,
            fontFamily: 'NotoSans',
          ),
          home: const AuthenticationWrapper(),
        ),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    
    // Show splash screen while checking auth state
    if (user == null) {
      // Initialize trial period for new users
      return const LoginScreen();
    } else {
      // User is authenticated, try to init trial if first time
      // This should typically be done in a better place with proper state management
      // For simplicity, we're doing it here
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      subscriptionService.initializeTrialPeriod();
      
      return const HomeScreen();
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.agriculture,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'फार्म असिस्ट AI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}