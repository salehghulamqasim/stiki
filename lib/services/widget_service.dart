import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

/// Widget Service for updating Android home screen widgets
/// Uses native Android auto-sizing text instead of Flutter image rendering
/// This ensures text never overflows regardless of widget resize
class WidgetService {
  static const String androidWidgetName = 'StikiWidget';

  /// Convert Flutter Color to hex string for Android
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Update widget with native text rendering
  /// Text will auto-size based on widget dimensions
  Future<void> updateStickyWidget({
    required String text,
    required Color color,
    required Color textColor,
    required String androidWidgetName,
    required String id,
  }) async {
    try {
      debugPrint("🔧 updateStickyWidget called with id: $id");

      // Save widget ID for click handling
      await HomeWidget.saveWidgetData('widget_id_$id', id);

      // Save text for native Android TextView
      await HomeWidget.saveWidgetData('widget_text_$id', text);

      // Save colors as hex strings for Android
      await HomeWidget.saveWidgetData(
        'widget_bg_color_$id',
        _colorToHex(color),
      );
      await HomeWidget.saveWidgetData(
        'widget_text_color_$id',
        _colorToHex(textColor),
      );

      debugPrint(
        "📝 Saved widget data: text='$text', bg=${_colorToHex(color)}, text=${_colorToHex(textColor)}",
      );

      // Trigger widget update
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
      );

      debugPrint("✅ Widget update complete for id: $id");
    } catch (e, stack) {
      debugPrint("❌ Widget update error: $e");
      debugPrint("Stack: $stack");
    }
  }

  /// Request to pin a new widget to home screen
  Future<void> requestWidgetPinning(String name) async {
    try {
      await HomeWidget.requestPinWidget(name: name);
    } catch (e) {
      debugPrint("Failed to request pin widget: $e");
    }
  }
}
