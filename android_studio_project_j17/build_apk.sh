#!/bin/bash

# FarmAssistAI APK build script with compatible Java 21 settings
# This script ensures proper environment configuration for builds with Java 21

echo "==============================================="
echo "FarmAssistAI Android Build Script"
echo "Compatible with Java 21, Gradle 8.4, Android Gradle Plugin 8.1.0"
echo "==============================================="

# Check if Java 21 is installed
java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
if [[ $java_version == 21* ]]; then
  echo "[✓] Java 21 detected: $java_version"
else
  echo "[✗] Warning: Java 21 not detected. Current version: $java_version"
  echo "    This project requires Java 21 for compatibility."
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Build aborted. Please install Java 21 and try again."
    exit 1
  fi
fi

# Set environment variable to avoid warning about Gradle daemon
export GRADLE_OPTS="-Dorg.gradle.daemon=false"

# Clean project
echo "[1/4] Cleaning project..."
flutter clean

# Get dependencies
echo "[2/4] Getting dependencies..."
flutter pub get

# Build APK
echo "[3/4] Building APK..."
flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
  echo "[4/4] Build successful!"
  echo "APK location: $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
  
  # Create app directory if it doesn't exist
  mkdir -p app
  
  # Copy APK to app directory with timestamp
  timestamp=$(date +"%Y%m%d_%H%M%S")
  cp build/app/outputs/flutter-apk/app-release.apk app/FarmAssistAI_$timestamp.apk
  
  echo "[✓] APK copied to: app/FarmAssistAI_$timestamp.apk"
else
  echo "[✗] Build failed. Please check the error messages above."
  exit 1
fi