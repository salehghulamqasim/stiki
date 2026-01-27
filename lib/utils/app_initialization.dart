// This file handles all the setup that happens when your app first starts.
// Think of it like turning on all the switches and plugging in all the cables
// before your app can actually run.
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:stiki/utils/navigation_helper.dart';
import 'package:stiki/services/background_services.dart';

class AppInitializer {
  /// This is the main setup function that gets called when your app starts.
  /// It does three important things:
  /// 1. Starts the background task that rotates quotes every hour
  /// 2. Listens for when someone taps a widget (so we can open the right screen)
  /// 3. Checks if the app was opened by tapping a widget (vs just opening normally)
  ///
  /// Returns the widget ID if the app was opened from a widget tap, or null otherwise.
  static Future<String?> initialize() async {
    // Step 1: Start the background engine
    // This makes sure quotes rotate automatically even when the app is closed
    await BackgroundService.initialize();

    // Step 2: Listen for widget taps when the app is already running
    // If someone taps a widget while the app is open in the background,
    // we want to jump to that widget's edit screen
    HomeWidget.widgetClicked.listen((dynamic data) {
      debugPrint("📱 Widget tapped! Raw data: $data");
      if (data == null) {
        debugPrint("📱 Widget tapped, but data is null.");
        return;
      }
      Uri? parsedUri;
      if (data is Uri) {
        parsedUri = data;
      } else if (data is String) {
        try {
          parsedUri = Uri.parse(data);
        } catch (e) {
          debugPrint("❌ Failed to parse URI from String: $data");
          return;
        }
      } else {
        debugPrint("❌ Unknown data type for widget tap: ${data.runtimeType}");
        return;
      }
      final String widgetId = parsedUri.authority;
      debugPrint("📱 Navigating to widget with ID: $widgetId");
      NavigationHelper.navigateToWidget(widgetId);
    });

    // Step 3: Check if the app was opened by tapping a widget
    // This handles the case where the app was completely closed,
    // and someone tapped a widget to open it
    final Uri? launchedUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    return launchedUri
        ?.authority; // Return the widget ID, or null if opened normally
  }
}
