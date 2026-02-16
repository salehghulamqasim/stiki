import 'package:home_widget/home_widget.dart';
import 'package:stiki/utils/navigation_helper.dart';
import 'package:stiki/services/background_services.dart';

class AppInitializer {
  static Future<String?> initialize() async {
    await BackgroundService.initialize();

    HomeWidget.widgetClicked.listen((dynamic data) {
      if (data == null) return;

      Uri? parsedUri;
      if (data is Uri) {
        parsedUri = data;
      } else if (data is String) {
        try {
          parsedUri = Uri.parse(data);
        } catch (e) {
          return;
        }
      } else {
        return;
      }

      String widgetId = parsedUri.authority;
      // Handle URI format: stiki://widget/<id>
      if (widgetId == 'widget' && parsedUri.pathSegments.isNotEmpty) {
        widgetId = parsedUri.pathSegments.last;
      }

      NavigationHelper.navigateToWidget(widgetId);
    });

    final Uri? launchedUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (launchedUri != null) {
      String widgetId = launchedUri.authority;
      // Handle URI format: stiki://widget/<id>
      if (widgetId == 'widget' && launchedUri.pathSegments.isNotEmpty) {
        widgetId = launchedUri.pathSegments.last;
      }
      return widgetId;
    }
    return null;
  }
}
