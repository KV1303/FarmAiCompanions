import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'api_service.dart';
import 'subscription_service.dart';
import 'ad_service.dart';
import 'firestore_service.dart';

class ServiceProvider extends StatelessWidget {
  final Widget child;
  final String apiBaseUrl;
  final bool testAdsMode;

  const ServiceProvider({
    Key? key,
    required this.child,
    required this.apiBaseUrl,
    this.testAdsMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication service
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        
        // Firestore service
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        
        // API service depends on authentication
        Provider<ApiService>(
          create: (_) => ApiService(baseUrl: apiBaseUrl),
        ),
        
        // Subscription service depends on Firestore
        Provider<SubscriptionService>(
          create: (_) => SubscriptionService(),
        ),
        
        // Ad service depends on subscription service
        Provider<AdService>(
          create: (context) => AdService(
            subscriptionService: Provider.of<SubscriptionService>(context, listen: false),
            testMode: testAdsMode,
          ),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: child,
    );
  }
}