# FarmAssist AI - Android Build Guide

This document provides instructions for building the FarmAssist AI Android application.

## Prerequisites

- Flutter SDK
- Android SDK
- Java Development Kit (JDK)
- Android Studio (recommended)

## Build Configuration

The Android app is configured with:

- Package name: `com.replit.farmassistai`
- Minimum SDK Version: 21 (Android 5.0+)
- Target SDK Version: 33
- AdMob integration
- Network security configuration for API access
- Dark mode support

## Building the APK

### Using the Build Script

1. Ensure you have Flutter installed and available in your PATH
2. Run the build script from the project root:

```bash
./build_android.sh
```

### Manual Build Steps

1. Navigate to the project root:

```bash
cd /path/to/farmassist_ai
```

2. Clean previous build artifacts:

```bash
flutter clean
```

3. Get dependencies:

```bash
flutter pub get
```

4. Build the release APK:

```bash
flutter build apk --release
```

5. The APK will be located at:

```
build/app/outputs/flutter-apk/app-release.apk
```

## AdMob Integration

- The app uses AdMob for monetization
- Test app ID is used during development
- Replace with production AdMob ID before Play Store submission

## Google Play Store Submission

Before submitting to Google Play Store:

1. Update AdMob App ID in `android/app/src/main/res/values/strings.xml`
2. Create proper signing key for production
3. Update `android/app/build.gradle` with proper signing configuration
4. Generate signed APK or App Bundle
5. Test thoroughly on multiple devices
6. Create privacy policy as required by Google Play Store
7. Prepare store listing assets (screenshots, feature graphic, etc.)

## Troubleshooting

If you encounter build issues:

1. Check Flutter doctor for environment issues:

```bash
flutter doctor -v
```

2. Verify Android SDK is properly configured
3. Check Gradle and project dependencies
4. Ensure all required permissions are defined in AndroidManifest.xml