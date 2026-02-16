import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String androidWidgetName = 'StikiWidget';

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> updateStickyWidget({
    required String text,
    required Color color,
    required Color textColor,
    required String androidWidgetName,
    required String id,
  }) async {
    try {
      await HomeWidget.saveWidgetData('widget_id_$id', id);
      await HomeWidget.saveWidgetData('widget_text_$id', text);
      await HomeWidget.saveWidgetData(
        'widget_bg_color_$id',
        _colorToHex(color),
      );
      await HomeWidget.saveWidgetData(
        'widget_text_color_$id',
        _colorToHex(textColor),
      );

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      // Silently handle widget update errors
    }
  }

  Future<void> requestWidgetPinning(String name) async {
    try {
      await HomeWidget.requestPinWidget(name: name);
    } catch (e) {
      // Silently handle pin request errors
    }
  }
}
