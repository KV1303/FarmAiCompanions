#!/bin/bash

echo "===== Building FarmAssist AI APK (Quick Build) ====="

# Skip cleaning to save time
echo "Skipping cleaning for faster build"

# Skip Flutter doctor
echo "Skipping Flutter doctor check"

# Create output directory
mkdir -p releases

# Create a basic APK using Flutter build apk with limited scope
echo "Building APK with minimal configuration..."
flutter build apk --release --split-per-abi --target-platform android-arm64 --no-tree-shake-icons --no-shrink

# Check if build was successful
if [ -f "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" ]; then
    echo "===== BUILD SUCCESSFUL ====="
    echo "APK file is located at: $(pwd)/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
    
    # Copy APK to easier to access location
    cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk releases/farmassist_ai_release.apk
    echo "A copy of the APK has been placed in: $(pwd)/releases/farmassist_ai_release.apk"
    
    # Show file size
    ls -lh releases/farmassist_ai_release.apk
else
    echo "===== BUILD FAILED ====="
    echo "Check the logs above for more information."
    exit 1
fi