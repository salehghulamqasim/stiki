import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:stiki/components/note_card.dart';

/// usually taking job outside my app like to home widget
/// thsi file has code service for sendTextnote and sendWeatherNote
/// ----- saveWidgetData, renderFlutterWidget, updateWidget -----
/// -----
/// saveWidgetData= puts text color into shared box that both flutter and phone can see
/// renderFlutterWidget= it takes noteCard and send it to phone to make exact looking of it
/// updateWidget= rings the doorbell on phone to say hey the data changed go look in the box and update it
/// -------

class WidgetService {
  // 1. Give it a name (we will use this in the native settings later)
  static const String androidWidgetName = 'StikiWidget';

  Future<void> updateStickyWidget({
    required String text,
    required Color color,
    required Color textColor,
    required String androidWidgetName,
    required String id,
  }) async {
    try {
      debugPrint("🔧 updateStickyWidget called with id: $id");

      // Save the widget ID for click handling (using instance ID)
      await HomeWidget.saveWidgetData('widget_id_$id', id);

      // Render the widget screenshot with instance-specific key
      debugPrint("🎨 Rendering widget to key: note_screenshot_$id");
      await HomeWidget.renderFlutterWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            color: Colors.transparent,
            child: NoteCard(text: text, color: color, textColor: textColor),
          ),
        ),
        key: 'note_screenshot_$id',
        logicalSize: const Size(200, 200),
      );

      // Trigger widget update for BOTH providers to be safe
      // This ensures the correct widget updates regardless of our detection logic
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
      );

      debugPrint("✅ Widget update complete for id: $id");
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  //when create new widget would ask widget to pin
  Future<void> requestWidgetPinning(String name) async {
    try {
      // This triggers the Android system dialog to pin the widget
      await HomeWidget.requestPinWidget(name: name);
    } catch (e) {
      debugPrint("Failed to request pin widget: $e");
    }
  }
}
