// This is the entry point of your app - the very first code that runs.
// It's like the main door to your house. Everything starts here.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:stiki/utils/app_initialization.dart';
import 'package:stiki/utils/navigation_helper.dart';
import 'package:stiki/pages/home_page.dart';

import 'package:stiki/pages/widget_screens_edit.dart';
import 'package:stiki/utils/storage_helper.dart';
import 'package:stiki/theme/app_colors.dart';
import 'package:stiki/animations/stiki_animations.dart';

void main() async {
  // This line is required - it tells Flutter to set up the framework
  WidgetsFlutterBinding.ensureInitialized();

  // Set up all the background services, listeners, and other setup stuff
  // This also checks if the app was opened by tapping a widget
  final widgetId = await AppInitializer.initialize();

  // Detect if device needs reduced animations (budget phones like Infinix)
  AnimationSettings.autoDetectPerformance();

  // Finally, start the app! This creates the MainApp widget and shows it on screen
  runApp(MainApp(startWidgetId: widgetId));
}

/// This is the root widget of your entire app.
/// It decides which screen to show first when the app opens.
class MainApp extends StatefulWidget {
  /// If the app was opened by tapping a widget, this will contain that widget's ID.
  /// Otherwise, it will be null and we'll just show the home page.
  final String? startWidgetId;
  const MainApp({super.key, this.startWidgetId});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  /// This holds the first screen we want to show.
  /// It starts as null, and once we figure out which screen to show,
  /// we store it here and the app displays it.
  Widget? _initialPage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-check if we need to navigate when app state changes
    if (widget.startWidgetId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigationHelper.navigateToWidget(widget.startWidgetId);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // As soon as this widget is created, figure out which page to show
    _loadInitialPage();
  }

  /// This function figures out which screen to show first.
  /// It runs in the background (async) so it doesn't freeze the app.
  Future<void> _loadInitialPage() async {
    final page = await _getStartPage();
    // Make sure the widget is still mounted (hasn't been destroyed)
    // before trying to update it
    if (mounted) {
      setState(() => _initialPage = page);
    }
  }

  /// This decides which screen to show:
  /// - If opened normally → show HomePage
  /// - If opened from a widget tap → show that widget's edit screen
  Future<Widget> _getStartPage() async {
    if (widget.startWidgetId == null || widget.startWidgetId!.isEmpty) {
      return const HomePage();
    }

    final target = await StorageHelper.getQuoteByIdOrNew(widget.startWidgetId!);
    return WidgetEditScreen(widget: target);
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Store dynamic colors in AppColors for use throughout the app
        if (darkDynamic != null) {
          AppColors.setDynamicColors(
            darkDynamic.surfaceContainer, // Darker surface for widget
            darkDynamic.onSurface,
          );
        }
        if (lightDynamic != null) {
          AppColors.setDynamicLightColors(
            lightDynamic
                .primaryContainer, // Distinct primary container for light widget
            lightDynamic.onPrimaryContainer,
          );
        }

        return ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              // This key lets us navigate from anywhere in the app (like when a widget is tapped)
              navigatorKey: NavigationHelper.navigatorKey,
              // Hide the debug banner in the top right corner
              debugShowCheckedModeBanner: false,
              // Show the initial page, or an empty scaffold while we're still loading
              home: _initialPage == null
                  ? Scaffold(backgroundColor: AppColors.background)
                  : _initialPage!,
            );
          },
        );
      },
    );
  }
}

// Re-importing missing constants if needed
const bool kDebugMode = !bool.fromEnvironment('dart.vm.product');
