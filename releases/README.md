# FarmAssistAI APK Download Information

## How to Download the APK

Since building a full Flutter APK directly in this environment has limitations, here are your options to get the FarmAssistAI APK:

### Option 1: Use the WebView APK (Recommended for Testing)

We've created a WebView wrapper APK that loads the FarmAssistAI web app directly. This is ideal for testing and preview purposes:

1. Download from: https://farmassistai.replit.app/download/farmassist_webview.apk
   - This APK is approximately 5MB in size
   - Updates automatically as the web app is updated
   - Requires internet connection to function

### Option 2: Use Flutter to Build Locally

If you have Flutter installed on your local machine, you can build the full-featured native APK:

1. Clone the repository to your local machine
2. Run these commands:
   ```
   flutter pub get
   flutter build apk --release
   ```
3. The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

### Option 3: Download from Release Site

When the app is fully published, it will be available at:
- Google Play Store: https://play.google.com/store/apps/details?id=com.replit.farmassistai
- App website: https://farmassistai.replit.app/download

## Installation Instructions

1. On your Android device, make sure to enable "Install from Unknown Sources" in your security settings
2. Download the APK file
3. Tap on the downloaded file to install
4. Open the app from your app drawer

## Current Features in the APK

- AI-powered crop disease detection
- Real-time market price monitoring
- Weather forecasting with agricultural recommendations
- Complete Hindi language support
- Farm management tools
- Subscription model with 7-day free trial