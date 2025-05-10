import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'providers/ad_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/field_monitoring/field_dashboard_screen.dart';
import 'screens/disease_detection/disease_detection_screen.dart';
import 'screens/market_prices/market_prices_screen.dart';
import 'screens/weather/weather_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/privacy_policy/privacy_policy_screen.dart';
import 'utils/localization.dart';
import 'widgets/consent_dialog.dart';

class FarmAssistApp extends StatelessWidget {
  const FarmAssistApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final adProvider = Provider.of<AdProvider>(context);
    
    // Check if we need to show the consent dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!adProvider.consentRequested && !authProvider.isLoading) {
        // Show consent dialog on first app launch
        _showConsentDialog(context);
      }
    });

    return MaterialApp(
      title: 'FarmAssist AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        hintColor: AppColors.accentColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
          displayMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
          displaySmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.textColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.textColor,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      locale: languageProvider.currentLocale,
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('hi', 'IN'), // Hindi
      ],
      localizationsDelegates: const [
        // AppLocalizations.delegate, // Commented out temporarily for web demo
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: authProvider.isLoading
          ? const SplashScreen()
          : authProvider.isFirstTime
              ? const OnboardingScreen()
              : authProvider.isAuthenticated
                  ? const HomeScreen()
                  : const LoginScreen(),
      routes: {
        AppConstants.routeSplash: (context) => const SplashScreen(),
        AppConstants.routeOnboarding: (context) => const OnboardingScreen(),
        AppConstants.routeLogin: (context) => const LoginScreen(),
        AppConstants.routeRegister: (context) => const RegisterScreen(),
        AppConstants.routeHome: (context) => const HomeScreen(),
        AppConstants.routeFieldDashboard: (context) => const FieldDashboardScreen(),
        AppConstants.routeDiseaseDetection: (context) => const DiseaseDetectionScreen(),
        AppConstants.routeMarketPrices: (context) => const MarketPricesScreen(),
        AppConstants.routeWeather: (context) => const WeatherScreen(),
        AppConstants.routeProfile: (context) => const ProfileScreen(),
        AppConstants.routePrivacyPolicy: (context) => const PrivacyPolicyScreen(),
      },
    );
  }
  
  Future<void> _showConsentDialog(BuildContext context) async {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    // Show the consent dialog
    final result = await ConsentDialog.show(context);
    
    // Set user preference for ads
    if (result == true) {
      // User accepted personalized ads
      adProvider.setPersonalizedAdsEnabled(true);
      // Initialize AdMob with personalized ads
      adProvider.initializeAds(true);
    } else {
      // User declined personalized ads, but we still show non-personalized ads
      adProvider.setPersonalizedAdsEnabled(false);
      // Initialize AdMob with non-personalized ads
      adProvider.initializeAds(false);
    }
  }
}
