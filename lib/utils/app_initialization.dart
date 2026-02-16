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
      final String widgetId = parsedUri.authority;
      NavigationHelper.navigateToWidget(widgetId);
    });

    final Uri? launchedUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    return launchedUri?.authority;
  }
}
