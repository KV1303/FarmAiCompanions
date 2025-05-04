#!/bin/bash

# Exit on error
set -e

echo "===== Building FarmAssist AI APK ====="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Flutter could not be found. Please install Flutter first."
    exit 1
fi

# Ensure proper Flutter directory structure
if [ ! -d "lib" ]; then
    echo "Error: 'lib' directory not found. This script must be run from the Flutter project root."
    exit 1
fi

# Clean previous build artifacts
echo "Cleaning previous build artifacts..."
flutter clean

# Get Flutter dependencies
echo "Getting dependencies..."
flutter pub get

# Run Flutter doctor to check environment
echo "Running Flutter doctor..."
flutter doctor -v

# Build the APK
echo "Building APK..."
flutter build apk --release

# Check if build was successful
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "===== BUILD SUCCESSFUL ====="
    echo "APK file is located at: $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
    
    # Copy APK to easier to access location
    mkdir -p releases
    cp build/app/outputs/flutter-apk/app-release.apk releases/farmassist_ai_release_$(date +%Y%m%d).apk
    echo "A copy of the APK has been placed in: $(pwd)/releases/farmassist_ai_release_$(date +%Y%m%d).apk"
else
    echo "===== BUILD FAILED ====="
    echo "Check the logs above for more information."
    exit 1
fi