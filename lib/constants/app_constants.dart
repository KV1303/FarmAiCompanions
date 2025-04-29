class AppConstants {
  // Routes
  static const String routeSplash = '/splash';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeHome = '/home';
  static const String routeFieldDashboard = '/field_dashboard';
  static const String routeDiseaseDetection = '/disease_detection';
  static const String routeMarketPrices = '/market_prices';
  static const String routeWeather = '/weather';
  static const String routeProfile = '/profile';

  // API endpoints
  static const String baseUrl = 'https://api.farmonaut.com/v1';
  static const String weatherApiUrl = 'https://api.visualcrossing.com/xt/weather/forecast';
  static const String eNamApiUrl = 'https://api.enam.gov.in/v1';
  
  // Shared preferences keys
  static const String prefIsFirstTime = 'is_first_time';
  static const String prefAuthToken = 'auth_token';
  static const String prefUserId = 'user_id';
  static const String prefLanguage = 'language';
  
  // Hive box names
  static const String userBox = 'user_box';
  static const String fieldBox = 'field_box';
  static const String cropBox = 'crop_box';
  static const String weatherBox = 'weather_box';
  static const String marketPriceBox = 'market_price_box';
  static const String diseaseBox = 'disease_box';
  
  // ML model
  static const String modelPath = 'assets/model.tflite';
  static const String labelsPath = 'assets/labels.txt';
  
  // Common constants
  static const int cacheDurationHours = 24;
  static const double defaultLatitude = 20.5937; // Default location for India
  static const double defaultLongitude = 78.9629; // Default location for India
}
