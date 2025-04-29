import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/field_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/market_provider.dart';
import 'providers/disease_provider.dart';
import 'providers/language_provider.dart';

// Simplified main method for web demo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For web demo, we'll skip the Firebase and Hive initialization
  // In a real app, we would conditionally initialize services based on platform

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FieldProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => DiseaseProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const FarmAssistApp(),
    ),
  );
}
