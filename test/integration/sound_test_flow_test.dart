import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projects/main.dart' as app;
import 'package:projects/features/sound_test/views/screens/test_page.dart';
import 'package:projects/core/main_nav.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Sound Test Flow Integration Tests', () {
    testWidgets('Complete sound test flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find and navigate to the Sound Test tab
      final soundTestTabFinder = find.byIcon(Icons.hearing);
      await tester.tap(soundTestTabFinder);
      await tester.pumpAndSettle();

      // Verify we're on the Sound Test page
      expect(find.byType(TestPage), findsOneWidget);

      // Find and tap the start test button
      final startButton = find.text('Start Test');
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Complete the test for all frequencies
      // This will depend on your actual implementation, but generally:
      // 1. Start with 250Hz test for left ear
      // 2. Adjust volume until heard
      // 3. Continue to next frequency
      // 4. Repeat for all frequencies for left ear
      // 5. Switch to right ear and repeat

      // For demonstration, we'll simulate increasing volume and confirming for each frequency stage
      // This would need to be adjusted based on your actual UI flow

      // Simulate the complete test flow for left ear
      for (int i = 0; i < 6; i++) {
        // Assuming 6 frequency tests
        // Find the volume slider and adjust it
        final slider = find.byType(Slider);
        expect(slider, findsOneWidget);

        // Increase volume until heard
        await tester.drag(slider, const Offset(100.0, 0.0));
        await tester.pumpAndSettle();

        // Tap the "I can hear it" button
        final hearButton = find.text('I can hear it');
        expect(hearButton, findsOneWidget);
        await tester.tap(hearButton);
        await tester.pumpAndSettle();
      }

      // Now we should be at the ear switching stage
      final switchEarText = find.textContaining('Switch to Right Ear');
      expect(switchEarText, findsOneWidget);

      // Confirm ear switch
      final confirmSwitch = find.text('Continue');
      await tester.tap(confirmSwitch);
      await tester.pumpAndSettle();

      // Repeat for right ear
      for (int i = 0; i < 6; i++) {
        // Assuming 6 frequency tests again
        // Find the volume slider and adjust it
        final slider = find.byType(Slider);
        expect(slider, findsOneWidget);

        // Increase volume until heard
        await tester.drag(slider, const Offset(100.0, 0.0));
        await tester.pumpAndSettle();

        // Tap the "I can hear it" button
        final hearButton = find.text('I can hear it');
        expect(hearButton, findsOneWidget);
        await tester.tap(hearButton);
        await tester.pumpAndSettle();
      }

      // Check that we've completed the test
      expect(find.text('Test Completed'), findsOneWidget);

      // Verify we can save the test results
      final saveButton = find.text('Save Results');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Check that the save dialog appears
      expect(find.text('Save Test Results'), findsOneWidget);

      // Enter a name for the test result
      final nameField = find.byType(TextField);
      await tester.enterText(nameField, 'Integration Test Result');
      await tester.pumpAndSettle();

      // Submit the save dialog
      final confirmSave = find.text('Save');
      await tester.tap(confirmSave);
      await tester.pumpAndSettle();

      // Verify we're back at the main sound test page with success message
      expect(find.text('Test saved successfully'), findsOneWidget);
    });
  });
}
