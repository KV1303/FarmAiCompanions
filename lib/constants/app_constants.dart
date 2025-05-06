/// Class holding app-wide constant values
class AppConstants {
  // App information
  static const String appName = 'FarmAssistAI';
  static const String appVersion = '1.0.0';
  
  // Route names
  static const String routeSplash = '/splash';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeHome = '/';
  static const String routeFieldDashboard = '/field-dashboard';
  static const String routeDiseaseDetection = '/disease-detection';
  static const String routeMarketPrices = '/market-prices';
  static const String routeWeather = '/weather';
  static const String routeProfile = '/profile';
  static const String routeSubscription = '/subscription';
  static const String routePremiumArticles = '/premium-articles';
  static const String routePremiumArticleDetail = '/premium-article-detail';
  static const String routePrivacyPolicy = '/privacy-policy';
  
  // Default values
  static const int fieldRefreshInterval = 60; // seconds
  static const int weatherRefreshInterval = 1800; // seconds (30 minutes)
  static const int marketPricesRefreshInterval = 3600; // seconds (1 hour)
  
  // API endpoints
  static const String apiBaseUrl = 'https://api.farmassistai.com';
  static const String weatherApiEndpoint = '/api/weather';
  static const String marketPricesApiEndpoint = '/api/market-prices';
  static const String diseaseDetectionApiEndpoint = '/api/disease-detection';
  static const String fieldMonitoringApiEndpoint = '/api/field-monitoring';
  
  // Marketplace Constants
  static const double marketplaceCommissionRate = 0.05; // 5% commission
  static const int minMarketplaceOrderAmount = 100; // Minimum order ₹100
  
  // Storage keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUserId = 'user_id';
  static const String storageKeyUserName = 'user_name';
  static const String storageKeyLanguage = 'language_code';
  static const String storageKeyOnboardingComplete = 'onboarding_complete';
  static const String storageKeyTrialStartDate = 'trial_start_date';
  static const String storageKeyTrialEndDate = 'trial_end_date';
  
  // Trial period in days
  static const int trialPeriodDays = 7;
  
  // Subscription prices in INR
  static const double monthlySubscriptionPrice = 59.0;
  static const double yearlySubscriptionPrice = 99.0;
  
  // Timeout durations in seconds
  static const int apiRequestTimeout = 30;
  static const int uploadTimeout = 180;
  
  // Maximum limits
  static const int maxFieldsPerUser = 10;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxChatHistoryMessages = 50;
}