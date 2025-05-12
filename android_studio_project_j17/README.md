# FarmAssistAI - Flutter Project for Android Studio

This project is configured for optimal compatibility with Android Studio and Java 17.

## Project Specifications

| Component                     | Version    | Notes                       |
| ----------------------------- | ---------- | --------------------------- |
| Java SDK                      | **17**     | Compatible with Gradle 7.x  |
| Gradle                        | **7.6**    | Supports Java 17, stable    |
| Android Gradle Plugin         | **7.4.2**  | Matches Gradle 7.6          |
| Flutter SDK                   | **>=3.0.0** | Compatible with all dependencies |
| Android compileSdkVersion     | **33**    | Android 13                  |

## Setup Instructions

1. Open this project in Android Studio
2. Ensure Java 17 is configured in Android Studio
3. Let Gradle sync complete
4. Run flutter pub get to download dependencies
5. Build the app with `flutter build apk --release`

## Dependencies

All dependencies have been locked to stable versions to ensure compatibility:

- **UI libraries**: Flutter Material, Google Fonts, Flutter SVG
- **State management**: Provider 6.0.5
- **Firebase**: Core, Auth, Firestore, Analytics
- **Ads**: Google Mobile Ads 3.0.0
- **Notifications**: flutter_local_notifications 13.0.0 (compatible version)

## Build Notes

This project is specifically configured for compatibility with:
- Android Studio
- Java 17 (not newer versions)
- Gradle 7.6
- Android Gradle Plugin 7.4.2

The configuration avoids issues with:
- Class file major version incompatibilities
- Missing Linux plugins
- Gradle wrapper errors