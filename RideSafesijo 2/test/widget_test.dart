import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridesafe/main.dart';

void main() {
  group('RideSafe App Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('RideSafe app smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(MaterialApp(home: MyApp()));
      await tester.pumpAndSettle();

      // Verify that the intro page shows
      expect(find.text('RideSafe'), findsOneWidget);
      expect(find.text('Your Smart Motorcycle Guardian'), findsOneWidget);

      // Verify that the Get Started button exists
      expect(find.text('Get Started'), findsOneWidget);

      // Tap the Get Started button
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
    });

    testWidgets('Navigation test', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: MyApp()));
      await tester.pumpAndSettle();

      // Test basic navigation
      expect(find.text('Get Started'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
    });
  });
}
