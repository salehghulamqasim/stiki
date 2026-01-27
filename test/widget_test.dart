import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stiki/pages/home_page.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Mock HomeWidget method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('home_widget/channel'), (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'getInstalledWidgets') {
            return [];
          }
          return null;
        });
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We wrap in ScreenUtilInit because HomePage uses it
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => const MaterialApp(home: HomePage()),
      ),
    );

    // Verify that the title shows up
    expect(find.text('Stiki'), findsOneWidget);
    expect(find.text('YOUR DAILY SOUL SPACE'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
