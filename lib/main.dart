import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/field_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/market_provider.dart';
import 'providers/disease_provider.dart';
import 'providers/language_provider.dart';
import 'providers/ad_provider.dart';

// Main method with AdMob initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob SDK
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await MobileAds.instance.initialize();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FieldProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => DiseaseProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()..initialize()),
      ],
      child: const FarmAssistApp(),
    ),
  );
}
