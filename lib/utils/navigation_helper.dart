import 'package:flutter/material.dart';
import 'package:stiki/pages/widget_screens_edit.dart';
import 'package:stiki/utils/storage_helper.dart';

class NavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> navigateToWidget(String? id) async {
    if (id == null || id.isEmpty) return;

    final target = await StorageHelper.getQuoteByIdOrNew(id);

    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => WidgetEditScreen(widget: target)),
    );
  }
}
