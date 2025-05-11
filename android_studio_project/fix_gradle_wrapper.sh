#!/bin/bash

echo "===== Fixing Gradle Wrapper for FarmAssistAI ====="

# Set proper permissions
chmod +x ./android/gradlew
echo "✅ Set execute permissions on gradlew script"

# Ensure the Gradle version is correct
GRADLE_VERSION="7.5"
GRADLE_PROPERTIES="./android/gradle/wrapper/gradle-wrapper.properties"

if [ -f "$GRADLE_PROPERTIES" ]; then
    echo "✅ Gradle wrapper properties file exists at $GRADLE_PROPERTIES"
else
    echo "❌ Gradle wrapper properties file not found"
    
    # Create directory if needed
    mkdir -p ./android/gradle/wrapper
    
    # Create properties file
    echo "distributionBase=GRADLE_USER_HOME" > "$GRADLE_PROPERTIES"
    echo "distributionPath=wrapper/dists" >> "$GRADLE_PROPERTIES"
    echo "zipStoreBase=GRADLE_USER_HOME" >> "$GRADLE_PROPERTIES"
    echo "zipStorePath=wrapper/dists" >> "$GRADLE_PROPERTIES"
    echo "distributionUrl=https\\://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip" >> "$GRADLE_PROPERTIES"
    
    echo "✅ Created gradle-wrapper.properties file"
fi

# Check if wrapper jar exists
if [ -f "./android/gradle/wrapper/gradle-wrapper.jar" ]; then
    echo "✅ Gradle wrapper JAR exists"
else
    echo "❌ Gradle wrapper JAR not found. Downloading..."
    
    # Try to download the distribution and extract the JAR
    TMP_DIR=$(mktemp -d)
    wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -O $TMP_DIR/gradle.zip
    
    if [ $? -eq 0 ]; then
        mkdir -p $TMP_DIR/gradle
        unzip -q $TMP_DIR/gradle.zip -d $TMP_DIR/gradle
        
        # Copy the wrapper JAR if found
        WRAPPER_JAR=$(find $TMP_DIR/gradle -name "gradle-wrapper*.jar" | grep -v "shared" | head -n 1)
        
        if [ -n "$WRAPPER_JAR" ]; then
            cp $WRAPPER_JAR ./android/gradle/wrapper/gradle-wrapper.jar
            echo "✅ Downloaded and installed gradle-wrapper.jar"
        else
            echo "❌ Failed to find gradle-wrapper.jar in the downloaded distribution"
        fi
        
        # Clean up
        rm -rf $TMP_DIR
    else
        echo "❌ Failed to download Gradle distribution"
    fi
fi

echo "===== Gradle Wrapper Fix Complete ====="
echo "You can now run './android/gradlew assembleRelease' to build the APK"