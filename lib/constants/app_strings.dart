class AppStrings {
  // App name
  static const String appName = 'FarmAssist AI';
  
  // Authentication
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String logout = 'Logout';
  static const String name = 'Name';
  static const String phoneNumber = 'Phone Number';
  static const String location = 'Location';
  
  // Onboarding
  static const String onboardingTitle1 = 'Monitor Your Fields';
  static const String onboardingDesc1 = 'Track crop health with satellite imagery and get real-time insights.';
  static const String onboardingTitle2 = 'Detect Diseases Early';
  static const String onboardingDesc2 = 'Take a picture of your crop and our AI will identify potential diseases.';
  static const String onboardingTitle3 = 'Track Market Prices';
  static const String onboardingDesc3 = 'Get real-time updates on current market prices for your crops.';
  static const String getStarted = 'Get Started';
  static const String skip = 'Skip';
  static const String next = 'Next';
  
  // Home
  static const String welcome = 'Welcome';
  static const String yourFields = 'Your Fields';
  static const String addNewField = 'Add New Field';
  static const String weatherForecast = 'Weather Forecast';
  static const String marketPrices = 'Market Prices';
  static const String cropHealth = 'Crop Health';
  static const String viewAll = 'View All';
  
  // Field Monitoring
  static const String fieldMonitoring = 'Field Monitoring';
  static const String fieldDetails = 'Field Details';
  static const String fieldName = 'Field Name';
  static const String cropType = 'Crop Type';
  static const String area = 'Area';
  static const String sowingDate = 'Sowing Date';
  static const String expectedHarvest = 'Expected Harvest';
  static const String ndviIndex = 'NDVI Index';
  static const String soilMoisture = 'Soil Moisture';
  static const String fieldHealth = 'Field Health';
  static const String hectares = 'hectares';
  static const String acres = 'acres';
  
  // Disease Detection
  static const String diseaseDetection = 'Disease Detection';
  static const String takePicture = 'Take Picture';
  static const String selectFromGallery = 'Select From Gallery';
  static const String analyzing = 'Analyzing...';
  static const String detectedDisease = 'Detected Disease';
  static const String diseaseName = 'Disease Name';
  static const String confidence = 'Confidence';
  static const String symptoms = 'Symptoms';
  static const String treatment = 'Treatment';
  static const String preventiveMeasures = 'Preventive Measures';
  static const String noDiseaseDetected = 'No Disease Detected';
  static const String healthyPlant = 'Healthy Plant';
  
  // Market Prices
  static const String marketPriceTracker = 'Market Price Tracker';
  static const String crop = 'Crop';
  static const String price = 'Price';
  static const String market = 'Market';
  static const String date = 'Date';
  static const String priceHistory = 'Price History';
  static const String currentPrice = 'Current Price';
  static const String minPrice = 'Min Price';
  static const String maxPrice = 'Max Price';
  static const String avgPrice = 'Avg Price';
  static const String rupeeSymbol = '₹';
  static const String perQuintal = 'per quintal';
  
  // Weather
  static const String weather = 'Weather';
  static const String today = 'Today';
  static const String forecast = 'Forecast';
  static const String temperature = 'Temperature';
  static const String humidity = 'Humidity';
  static const String rainfall = 'Rainfall';
  static const String wind = 'Wind';
  static const String alerts = 'Alerts';
  static const String precipitation = 'Precipitation';
  static const String celsius = '°C';
  static const String fahrenheit = '°F';
  static const String millimeters = 'mm';
  static const String kmPerHour = 'km/h';
  static const String percent = '%';
  
  // Profile
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String language = 'Language';
  static const String settings = 'Settings';
  static const String help = 'Help';
  static const String about = 'About';
  static const String version = 'Version';
  static const String contactUs = 'Contact Us';
  static const String termsAndConditions = 'Terms and Conditions';
  static const String privacyPolicy = 'Privacy Policy';
  
  // General
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String retry = 'Retry';
  static const String noDataAvailable = 'No Data Available';
  static const String comingSoon = 'Coming Soon';
  static const String noInternetConnection = 'No Internet Connection';
  static const String tryAgain = 'Try Again';
  
  // Language options
  static const String english = 'English';
  static const String hindi = 'हिंदी';
  
  // Common crop types
  static const List<String> cropTypes = [
    'Rice',
    'Wheat',
    'Maize',
    'Cotton',
    'Sugarcane',
    'Soybean',
    'Groundnut',
    'Mustard',
    'Potato',
    'Tomato',
    'Onion',
    'Chilli',
  ];
  
  // Common crop diseases
  static const List<String> commonDiseases = [
    'Bacterial Leaf Blight',
    'Brown Spot',
    'Leaf Smut',
    'Blast',
    'Powdery Mildew',
    'Rust',
    'Leaf Spot',
    'Anthracnose',
    'Downy Mildew',
    'Early Blight',
    'Late Blight',
    'Healthy',
  ];
  
  // Notifications
  static const String notifications = 'Notifications';
  static const String noNotifications = 'No Notifications';
  
  // Error messages
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPassword = 'Password must be at least 6 characters';
  static const String invalidPhoneNumber = 'Please enter a valid phone number';
  static const String apiError = 'Failed to connect to server. Please check your internet connection.';
  static const String authError = 'Authentication failed. Please check your credentials.';
  static const String networkError = 'Network error. Please check your internet connection.';
  static const String permissionDenied = 'Permission denied. Please grant the required permissions.';
}
