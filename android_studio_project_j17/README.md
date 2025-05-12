# FarmAssistAI - Flutter Project for Android Studio

This project is configured for optimal compatibility with Android Studio and Java 21.

## Project Specifications

| Component                     | Version    | Notes                       |
| ----------------------------- | ---------- | --------------------------- |
| Java SDK                      | **21**     | Compatible with Gradle 8.x  |
| Gradle                        | **8.4**    | Supports Java 21, stable    |
| Android Gradle Plugin         | **8.1.0**  | Matches Gradle 8.4          |
| Flutter SDK                   | **>=3.0.0** | Compatible with all dependencies |
| Android compileSdkVersion     | **34**    | Android 14                  |

## Setup Instructions

1. Open this project in Android Studio
2. Ensure Java 21 is configured in Android Studio (File > Settings > Build, Execution, Deployment > Build Tools > Gradle > Gradle JDK)
3. Let Gradle sync complete
4. Run flutter pub get to download dependencies
5. Build the app with `flutter build apk --release`

## Dependencies

All dependencies have been locked to stable versions to ensure compatibility:

- **UI libraries**: Flutter Material, Google Fonts, Flutter SVG
- **State management**: Provider 6.0.5
- **Firebase**: Core, Auth, Firestore, Analytics
- **Ads**: Google Mobile Ads 3.0.0
- **Notifications**: flutter_local_notifications 13.0.0

## Build Notes

This project is specifically configured for compatibility with:
- Android Studio
- Java 21
- Gradle 8.4
- Android Gradle Plugin 8.1.0

The configuration includes additional JVM arguments required for Java 21 compatibility:
- Required export and open flags for Java modules
- Proper Kotlin daemon settings
- Extra memory allocation for Gradle