# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# HomeWidget
-keep class es.antonborri.home_widget.** { *; }

# Stiki Widget Receivers - CRITICAL for release builds
-keep class com.stiki.app.StikiWidgetDark { *; }
-keep class com.stiki.app.StikiWidgetLight { *; }

# Play Core Library - Fix for deferred components
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
