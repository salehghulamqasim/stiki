// This file helps us navigate to different screens in the app.
// It's especially useful when we need to jump to a screen from outside
// the normal widget tree (like when a widget is tapped on the home screen).
import 'package:flutter/material.dart';
import 'package:stiki/pages/widget_screens_edit.dart';
import 'package:stiki/utils/storage_helper.dart';

class NavigationHelper {
  /// This is a special key that lets us control navigation from anywhere in the app.
  /// Normally, you can only navigate from inside a widget that has access to the
  /// BuildContext. But sometimes (like when a widget is tapped), we need to navigate
  /// from code that doesn't have a context. This key gives us that power.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// When someone taps a widget on their home screen, this function opens
  /// the edit screen for that specific widget.
  ///
  /// It finds the widget by its ID, loads it from storage, and then shows
  /// the edit screen so the user can change the quote or settings.
  static Future<void> navigateToWidget(String? id) async {
    debugPrint(
      "🧭 NavigationHelper.navigateToWidget called with widgetId: $id",
    ); // <-- Debug print added
    // Safety check: if there's no ID, we can't do anything
    if (id == null || id.isEmpty) return;

    // Load or create the widget
    final target = await StorageHelper.getQuoteByIdOrNew(id);

    // Use our special navigation key to push the edit screen
    // This works even though we're not inside a widget's build method
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => WidgetEditScreen(widget: target)),
    );
  }
}
