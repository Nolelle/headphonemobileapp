import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projects/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Preset Flow Integration Tests', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Create, edit, and delete a preset',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to presets tab
      await tester.tap(find.text('Presets'));
      await tester.pumpAndSettle();

      // Verify we're on the presets page
      expect(find.text('No presets available'), findsOneWidget);

      // Create a new preset
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify we're on the preset edit page
      expect(find.text('Edit Preset'), findsOneWidget);

      // Edit the preset name
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TextField).first, 'Integration Test Preset');
      await tester.pumpAndSettle();

      // Adjust the overall volume
      final Finder slider = find.byType(Slider).first;
      await tester.drag(slider, const Offset(50.0, 0.0));
      await tester.pumpAndSettle();

      // Toggle background noise reduction
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Go back to presets list
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify the preset was created
      expect(find.text('Integration Test Preset'), findsOneWidget);

      // Tap on the preset to activate it
      await tester.tap(find.text('Integration Test Preset'));
      await tester.pumpAndSettle();

      // Verify the edit and delete buttons appear
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Edit the preset
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Change the preset name
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Updated Preset');
      await tester.pumpAndSettle();

      // Go back to presets list
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify the preset was updated
      expect(find.text('Updated Preset'), findsOneWidget);

      // Tap on the preset to activate it
      await tester.tap(find.text('Updated Preset'));
      await tester.pumpAndSettle();

      // Delete the preset
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      // Verify the preset was deleted
      expect(find.text('No presets available'), findsOneWidget);
    });
  });
}
