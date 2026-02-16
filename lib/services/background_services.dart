import 'package:flutter/material.dart';
import 'dart:math';
import 'package:workmanager/workmanager.dart';
import 'package:stiki/utils/storage_helper.dart';
import 'package:stiki/services/widget_service.dart';
import 'package:stiki/theme/app_colors.dart';

class BackgroundService {
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((taskName, inputData) async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        final widgets = await StorageHelper.getQuotes();
        final now = DateTime.now();

        for (var widget in widgets) {
          if (widget.frequency == 'none') continue;
          if (widget.quotes.length < 2) continue;

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

          final timeSinceLastUpdate = now.difference(widget.lastUpdated);

          if (timeSinceLastUpdate >= interval) {
            // Move to a RANDOM quote (Shuffle)
            int nextIndex;
            int attempts = 0;
            do {
              nextIndex = Random().nextInt(widget.quotes.length);
              attempts++;
            } while (nextIndex == widget.currentIndex && attempts < 10);

            final nextQuote = widget.quotes[nextIndex];

            final fallbackColors = _getColorsForWidget(widget.widgetName);

            final updateBgColor = widget.backgroundColor != null
                ? Color(widget.backgroundColor!)
                : fallbackColors.backgroundColor;

            final updateTextColor = widget.textColor != null
                ? Color(widget.textColor!)
                : fallbackColors.textColor;

            await WidgetService().updateStickyWidget(
              text: nextQuote,
              color: updateBgColor,
              textColor: updateTextColor,
              androidWidgetName: widget.widgetName,
              id: widget.id,
            );

            await StorageHelper.saveQuote(
              nextQuote,
              id: widget.id,
              currentIndex: nextIndex,
              lastUpdated: now,
            );
          }
        }
        return Future.value(true);
      } catch (e) {
        return Future.value(false);
      }
    });
  }

  static ({Color backgroundColor, Color textColor}) _getColorsForWidget(
    String widgetName,
  ) {
    if (widgetName.contains('Dark')) {
      return (
        backgroundColor: AppColors.darkBackground,
        textColor: AppColors.textLight,
      );
    }
    return (
      backgroundColor: AppColors.yellowWidget,
      textColor: AppColors.textPrimary,
    );
  }

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);

    await Workmanager().registerPeriodicTask(
      "stiki_rotation_unified",
      "stiki_rotation_unified",
      frequency: const Duration(hours: 1),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }
}
