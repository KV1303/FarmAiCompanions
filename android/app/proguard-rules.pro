# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# AdMob specific rules
-keep class com.google.android.gms.ads.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep parcelable classes
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep R inner classes
-keepclassmembers class **.R$* {
    public static <fields>;
}