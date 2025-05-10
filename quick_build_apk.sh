#!/bin/bash

echo "===== Building FarmAssist AI APK (Quick Build) ====="

# Skip cleaning to save time
echo "Skipping cleaning for faster build"

# Skip Flutter doctor
echo "Skipping Flutter doctor check"

# Create output directory
mkdir -p releases

# Ensure we're using debug signing configuration
echo "Note: Using debug signing configuration which is more reliable..."

# Using more reliable build parameters to avoid parsing errors
echo "Building APK with improved configuration..."
flutter build apk --release --debug-signing-config --no-shrink

# Check if build was successful - check for both split and non-split APKs
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
elif [ -f "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" ]; then
    APK_PATH="build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
else
    echo "===== BUILD FAILED ====="
    echo "Could not find output APK file."
    echo "Check the logs above for more information."
    exit 1
fi

echo "===== BUILD SUCCESSFUL ====="
echo "APK file is located at: $(pwd)/${APK_PATH}"

# Copy APK to easier to access location
cp ${APK_PATH} releases/farmassist_ai_release.apk
echo "A copy of the APK has been placed in: $(pwd)/releases/farmassist_ai_release.apk"
echo "This APK should install properly without parsing errors."

# Show file size
ls -lh releases/farmassist_ai_release.apk

# Validation tip
echo ""
echo "============= IMPORTANT INSTALLATION NOTES ============="
echo "If you still encounter parsing errors when installing:"
echo "1. Make sure to allow installation from unknown sources in your device settings"
echo "2. Try installing directly from the device instead of transferring the APK"
echo "3. Make sure your device is compatible (Android 5.0+)"
echo "========================================================"