import 'package:flutter/material.dart';
import 'dart:math';
import 'package:workmanager/workmanager.dart';
import 'package:stiki/utils/storage_helper.dart';
import 'package:stiki/services/widget_service.dart';
import 'package:stiki/theme/app_colors.dart';

class BackgroundService {
  /// The engine that runs in the background.
  /// It wakes up, checks all widgets, and updates them if needed.
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((taskName, inputData) async {
      debugPrint("🕒 [BackgroundService] Rotation task started");

      try {
        final widgets = await StorageHelper.getQuotes();
        final now = DateTime.now();

        for (var widget in widgets) {
          // Skip widgets that don't need rotation (manual) or have no quotes
          if (widget.frequency == 'none' || widget.quotes.isEmpty) continue;

          // Determine the required interval
          Duration interval;
          if (widget.frequency == 'hourly') {
            interval = const Duration(hours: 1);
          } else if (widget.frequency == 'daily') {
            interval = const Duration(days: 1);
          } else if (widget.frequency == 'weekly') {
            interval = const Duration(days: 7);
          } else {
            continue;
          }

          // Check if enough time has passed since the last update
          final timeSinceLastUpdate = now.difference(widget.lastUpdated);

          if (timeSinceLastUpdate >= interval) {
            debugPrint(
              "🔄 Rotating widget ${widget.id}. Time since last: $timeSinceLastUpdate",
            );

            // Move to a RANDOM quote (Shuffle)
            // Ensure we don't pick the same one twice if possible
            int nextIndex;
            if (widget.quotes.length > 1) {
              do {
                nextIndex = Random().nextInt(widget.quotes.length);
              } while (nextIndex == widget.currentIndex);
            } else {
              nextIndex = 0;
            }
            final nextQuote = widget.quotes[nextIndex];

            // Determine theme colors dynamically from AppColors
            final isDark = widget.widgetName.contains('Dark');
            final bgColor = isDark
                ? AppColors.darkBackground
                : AppColors.yellowWidget;
            final textColor = isDark
                ? AppColors.textLight
                : AppColors.textPrimary;

            // 1. PUSH THE UPDATE TO THE HOME SCREEN (Visual update)
            await WidgetService().updateStickyWidget(
              text: nextQuote,
              color: bgColor,
              textColor: textColor,
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
          }
        }
        return Future.value(true);
      } catch (e) {
        debugPrint("❌ [BackgroundService] Error: $e");
        return Future.value(false);
      }
    });
  }

  /// Sets up the rotation robot to check for updates periodically.
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);

    // Check for rotation every 1 hour (Optimized for battery)
    // Since the fastest rotation is Hourly, checking more often is unnecessary.
    await Workmanager().registerPeriodicTask(
      "stiki_rotation_unified",
      "stiki_rotation_unified",
      frequency: const Duration(hours: 1),
      existingWorkPolicy:
          ExistingPeriodicWorkPolicy.keep, // FIXED: Don't reset timer
    );
  }
}
