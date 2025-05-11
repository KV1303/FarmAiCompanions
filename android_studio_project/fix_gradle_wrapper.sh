#!/bin/bash

echo "===== Fixing Gradle Wrapper for FarmAssistAI ====="

# Set proper permissions
chmod +x ./android/gradlew
echo "✅ Set execute permissions on gradlew script"

# Ensure the Gradle version is correct - using 8.3 for Java 21 compatibility
GRADLE_VERSION="8.3"
GRADLE_PROPERTIES="./android/gradle/wrapper/gradle-wrapper.properties"

if [ -f "$GRADLE_PROPERTIES" ]; then
    echo "✅ Updating Gradle wrapper properties file"
    
    # Update to Gradle 8.3 for Java 21 compatibility
    sed -i 's/distributionUrl=.*/distributionUrl=https\\:\/\/services.gradle.org\/distributions\/gradle-'"${GRADLE_VERSION}"'-all.zip/g' "$GRADLE_PROPERTIES"
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
    
    echo "✅ Created gradle-wrapper.properties file with Gradle 8.3"
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

# Fix build.gradle files for Java 21 compatibility
echo "Checking for Java version compatibility in build.gradle files..."

APP_BUILD_GRADLE="./android/app/build.gradle"
if [ -f "$APP_BUILD_GRADLE" ]; then
    # Update Java compatibility to Java 17
    sed -i 's/sourceCompatibility JavaVersion.VERSION_1_8/sourceCompatibility JavaVersion.VERSION_17/g' "$APP_BUILD_GRADLE"
    sed -i 's/targetCompatibility JavaVersion.VERSION_1_8/targetCompatibility JavaVersion.VERSION_17/g' "$APP_BUILD_GRADLE"
    sed -i 's/jvmTarget = .1.8./jvmTarget = .17./g' "$APP_BUILD_GRADLE"
    
    # Add namespace for AGP 8.x compatibility
    if ! grep -q "namespace" "$APP_BUILD_GRADLE"; then
        sed -i '/android {/a\\    namespace "com.replit.farmassistai"' "$APP_BUILD_GRADLE"
    fi
    
    # Update Kotlin stdlib version
    sed -i 's/kotlin-stdlib-jdk7/kotlin-stdlib-jdk8/g' "$APP_BUILD_GRADLE"
    sed -i 's/:1.6.10/:1.9.0/g' "$APP_BUILD_GRADLE"
    
    echo "✅ Updated app/build.gradle for Java 21 compatibility"
fi

ROOT_BUILD_GRADLE="./android/build.gradle"
if [ -f "$ROOT_BUILD_GRADLE" ]; then
    # Update Android Gradle Plugin and Kotlin versions
    sed -i 's/ext.kotlin_version = .1.6.10./ext.kotlin_version = .1.9.0./g' "$ROOT_BUILD_GRADLE"
    sed -i 's/com.android.tools.build:gradle:7.1.2/com.android.tools.build:gradle:8.1.0/g' "$ROOT_BUILD_GRADLE"
    
    echo "✅ Updated root build.gradle for Java 21 compatibility"
fi

GRADLE_PROPERTIES="./android/gradle.properties"
if [ -f "$GRADLE_PROPERTIES" ]; then
    # Add JVM args for Java 21 compatibility if not present
    if ! grep -q "add-exports" "$GRADLE_PROPERTIES"; then
        sed -i 's/org.gradle.jvmargs=.*/org.gradle.jvmargs=-Xmx2048M -Dkotlin.daemon.jvm.options\\="-Xmx2048M" --add-exports=java.base\/sun.nio.ch=ALL-UNNAMED --add-opens=java.base\/java.lang=ALL-UNNAMED --add-opens=java.base\/java.lang.reflect=ALL-UNNAMED --add-opens=java.base\/java.io=ALL-UNNAMED/g' "$GRADLE_PROPERTIES"
    fi
    
    # Add other required properties if not present
    if ! grep -q "android.nonFinalResIds" "$GRADLE_PROPERTIES"; then
        echo "android.nonFinalResIds=false" >> "$GRADLE_PROPERTIES"
    fi
    
    if ! grep -q "android.defaults.buildfeatures.buildconfig" "$GRADLE_PROPERTIES"; then
        echo "android.defaults.buildfeatures.buildconfig=true" >> "$GRADLE_PROPERTIES"
    fi
    
    echo "✅ Updated gradle.properties for Java 21 compatibility"
fi

echo "===== Gradle Wrapper Fix Complete ====="
echo "Your project has been updated to be compatible with Java 21 and Gradle 8.3"
echo "You can now run './android/gradlew assembleRelease' to build the APK"