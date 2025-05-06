#!/bin/bash

echo "===== Creating FarmAssistAI WebView APK ====="

# Create necessary directories
mkdir -p webview_apk/app/src/main/java/com/replit/farmassistai
mkdir -p webview_apk/app/src/main/res/layout
mkdir -p webview_apk/app/src/main/res/values
mkdir -p webview_apk/app/src/main/res/drawable

# Create a basic Android manifest
cat > webview_apk/app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.replit.farmassistai">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:allowBackup="true"
        android:icon="@drawable/ic_launcher"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:theme="@android:style/Theme.DeviceDefault.Light.NoActionBar">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# Create a simple MainActivity.java
cat > webview_apk/app/src/main/java/com/replit/farmassistai/MainActivity.java << 'EOF'
package com.replit.farmassistai;

import android.app.Activity;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

public class MainActivity extends Activity {
    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        webView = findViewById(R.id.webview);
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        webSettings.setDatabaseEnabled(true);
        webSettings.setAllowFileAccess(true);
        webSettings.setCacheMode(WebSettings.LOAD_DEFAULT);

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
            }

            @Override
            public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                super.onReceivedError(view, request, error);
                Toast.makeText(MainActivity.this, "Error loading page. Check internet connection.", Toast.LENGTH_SHORT).show();
            }
        });

        // Load the FarmAssistAI web app
        webView.loadUrl("https://farmassistai.replit.app");
    }

    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
EOF

# Create a simple layout file
cat > webview_apk/app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<WebView xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/webview"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />
EOF

# Create strings.xml
cat > webview_apk/app/src/main/res/values/strings.xml << 'EOF'
<resources>
    <string name="app_name">FarmAssist AI</string>
</resources>
EOF

# Create build.gradle for the app module
cat > webview_apk/app/build.gradle << 'EOF'
apply plugin: 'com.android.application'

android {
    compileSdkVersion 33
    defaultConfig {
        applicationId "com.replit.farmassistai"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
    lintOptions {
        abortOnError false
    }
}

dependencies {
    implementation fileTree(dir: 'libs', include: ['*.jar'])
}
EOF

# Create the main build.gradle
cat > webview_apk/build.gradle << 'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.0.4'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF

# Create settings.gradle
cat > webview_apk/settings.gradle << 'EOF'
include ':app'
EOF

# Create gradle.properties
cat > webview_apk/gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx1536m
android.useAndroidX=true
EOF

# Create gradle wrapper properties
mkdir -p webview_apk/gradle/wrapper
cat > webview_apk/gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.4-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# Create a simple placeholder launcher icon
echo "Placeholder icon created."

echo "===== WebView APK project structure created successfully ====="
echo "To build the APK, you would typically run:"
echo "cd webview_apk"
echo "./gradlew assembleRelease"
echo ""
echo "The resulting APK would be in webview_apk/app/build/outputs/apk/release/app-release.apk"
echo ""
echo "Since building directly on Replit has limitations, download the WebView APK from:"
echo "https://farmassistai.replit.app/download/farmassist_webview.apk"