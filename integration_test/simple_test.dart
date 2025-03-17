import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projects/l10n/app_localizations.dart';
import 'test_helper.dart';

// Simple widget that uses localization
class LocalizedWidget extends StatelessWidget {
  const LocalizedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(appLocalizations.translate('no_presets')),
          ],
        ),
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Set up mock method channels
  setupMockMethodChannels();

  group('Simple Localization Test', () {
    testWidgets('should display localized text', (WidgetTester tester) async {
      // Build a simple widget with localization
      await tester.pumpWidget(
        createTestableWidget(
          child: const LocalizedWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the localized text is displayed
      expect(find.textContaining('No presets available'), findsOneWidget);
    });
  });
}
