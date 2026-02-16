import 'package:flutter/material.dart';
import 'dart:math';
import 'package:workmanager/workmanager.dart';
import 'package:stiki/utils/storage_helper.dart';
import 'package:stiki/services/widget_service.dart';
import 'package:stiki/theme/app_colors.dart';

class BackgroundService {
  /// The engine that runs in the background.
  /// It wakes up, checks all widgets, and updates them if needed.
  ///
  /// NOTE: Android WorkManager has a minimum interval of 15 minutes.
  /// "Hourly" frequency will check every ~15 mins but only rotate after 1 hour.
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((taskName, inputData) async {
      // CRITICAL: Initialize Flutter bindings for background isolate
      // Without this, SharedPreferences won't work in the background process
      WidgetsFlutterBinding.ensureInitialized();

      debugPrint(
        "🕒 [BackgroundService] Rotation task started at ${DateTime.now()}",
      );

      try {
        final widgets = await StorageHelper.getQuotes();
        debugPrint("📋 Found ${widgets.length} widgets to check");
        final now = DateTime.now();

        for (var widget in widgets) {
          debugPrint(
            "🔍 Checking widget ${widget.id}: frequency=${widget.frequency}, quotes=${widget.quotes.length}",
          );

          // Skip widgets that don't need rotation (manual) or have insufficient quotes
          if (widget.frequency == 'none') {
            debugPrint("⏭️ Skipping ${widget.id}: frequency is 'none'");
            continue;
          }

          if (widget.quotes.length < 2) {
            debugPrint(
              "⏭️ Skipping ${widget.id}: only ${widget.quotes.length} quote(s), need at least 2 to shuffle",
            );
            continue;
          }

          // Determine the required interval
          Duration interval;
          if (widget.frequency == 'hourly') {
            interval = const Duration(hours: 1);
          } else if (widget.frequency == 'daily') {
            interval = const Duration(days: 1);
          } else if (widget.frequency == 'weekly') {
            interval = const Duration(days: 7);
          } else {
            debugPrint(
              "⏭️ Skipping ${widget.id}: unknown frequency '${widget.frequency}'",
            );
            continue;
          }

          // Check if enough time has passed since the last update
          final timeSinceLastUpdate = now.difference(widget.lastUpdated);
          debugPrint(
            "⏱️ Widget ${widget.id}: ${timeSinceLastUpdate.inMinutes} mins since last update (need ${interval.inMinutes} mins)",
          );

          if (timeSinceLastUpdate >= interval) {
            debugPrint(
              "🔄 ROTATING widget ${widget.id}. Time since last: $timeSinceLastUpdate",
            );

            // Move to a RANDOM quote (Shuffle)
            // Ensure we don't pick the same one twice
            int nextIndex;
            int attempts = 0;
            do {
              nextIndex = Random().nextInt(widget.quotes.length);
              attempts++;
            } while (nextIndex == widget.currentIndex && attempts < 10);

            final nextQuote = widget.quotes[nextIndex];
            debugPrint(
              "📝 New quote index: $nextIndex (was ${widget.currentIndex}), quote: '$nextQuote'",
            );

            // Get colors based on widget type (fallback)
            final fallbackColors = _getColorsForWidget(widget.widgetName);

            // Use saved colors if available to preserve user customization
            final updateBgColor = widget.backgroundColor != null
                ? Color(widget.backgroundColor!)
                : fallbackColors.backgroundColor;

            final updateTextColor = widget.textColor != null
                ? Color(widget.textColor!)
                : fallbackColors.textColor;

            // 1. PUSH THE UPDATE TO THE HOME SCREEN (Visual update)
            await WidgetService().updateStickyWidget(
              text: nextQuote,
              color: updateBgColor,
              textColor: updateTextColor,
              androidWidgetName: widget.widgetName,
              id: widget.id,
            );

            // 2. SAVE the work in shared storage (Data update)
            // IMPORTANT: Update 'lastUpdated' to NOW so the timer resets
            await StorageHelper.saveQuote(
              nextQuote,
              id: widget.id,
              currentIndex: nextIndex,
              lastUpdated: now, // Reset the timer
            );

            debugPrint("✅ Widget ${widget.id} rotation complete!");
          } else {
            debugPrint("⏳ Widget ${widget.id}: Not time yet, skipping");
          }
        }
        debugPrint(
          "🏁 [BackgroundService] Rotation task completed successfully",
        );
        return Future.value(true);
      } catch (e, stackTrace) {
        debugPrint("❌ [BackgroundService] Error: $e");
        debugPrint("📚 Stack trace: $stackTrace");
        return Future.value(false);
      }
    });
  }

  /// Get appropriate colors for a widget based on its name
  static ({Color backgroundColor, Color textColor}) _getColorsForWidget(
    String widgetName,
  ) {
    if (widgetName.contains('Dark')) {
      return (
        backgroundColor: AppColors.darkBackground,
        textColor: AppColors.textLight,
      );
    }
    // Default to yellow (light) for StikiWidgetLight and other variants
    // Note: Custom colors are stored in the widget's quote data, but for background rendering
    // we use the standard colors to avoid complexity. The widget will show the right color
    // because the image is rendered with the correct color at creation time.
    return (
      backgroundColor: AppColors.yellowWidget,
      textColor: AppColors.textPrimary,
    );
  }

  /// Sets up the rotation robot to check for updates periodically.
  ///
  /// NOTE: Android WorkManager minimum interval is 15 minutes.
  /// We set 1 hour frequency, but the actual execution time depends on:
  /// - Battery optimization settings
  /// - Doze mode
  /// - Device manufacturer restrictions
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);

    // Register periodic task for quote rotation
    // Note: WorkManager minimum interval is 15 minutes on Android
    await Workmanager().registerPeriodicTask(
      "stiki_rotation_unified",
      "stiki_rotation_unified",
      frequency: const Duration(hours: 1),
      existingWorkPolicy:
          ExistingPeriodicWorkPolicy.keep, // Don't reset timer on re-register
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    debugPrint("📅 [BackgroundService] Periodic rotation task registered");
  }
}
