import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/sound_test/widgets/audiogram.dart';

void main() {
  group('Audiogram Widget Tests', () {
    // Sample data for testing
    final leftEarData = {
      'L_user_250Hz_dB': 50.0,
      'L_user_500Hz_dB': 55.0,
      'L_user_1000Hz_dB': 60.0,
      'L_user_2000Hz_dB': 65.0,
      'L_user_4000Hz_dB': 70.0,
    };

    final rightEarData = {
      'R_user_250Hz_dB': 45.0,
      'R_user_500Hz_dB': 50.0,
      'R_user_1000Hz_dB': 55.0,
      'R_user_2000Hz_dB': 60.0,
      'R_user_4000Hz_dB': 65.0,
    };

    // Adjust test screen size to be larger to accommodate the audiogram
    Future<void> setLargeScreenSize(WidgetTester tester) async {
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      tester.binding.window.physicalSizeTestValue = const Size(1024, 1024);
      addTearDown(() {
        tester.binding.window.clearDevicePixelRatioTestValue();
        tester.binding.window.clearPhysicalSizeTestValue();
      });
    }

    testWidgets('renders correctly with sample data',
        (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build the widget inside a scroll view to avoid overflow
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Audiogram(
                leftEarData: leftEarData,
                rightEarData: rightEarData,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the audiogram renders without crashing
      expect(find.byType(Audiogram), findsOneWidget);

      // Check for custom painters that render the actual graph
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));

      // Check for frequency label
      expect(find.textContaining('Frequency'), findsOneWidget);

      // Look for hearing loss categories
      expect(find.textContaining('Normal'), findsOneWidget);
      expect(find.textContaining('Mild'), findsOneWidget);
      expect(find.textContaining('Moderate'), findsOneWidget);
      expect(find.textContaining('Severe'), findsOneWidget);
      expect(find.textContaining('Profound'), findsOneWidget);
    });

    testWidgets('updates when data changes', (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build with customized test widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: _AudiogramTestWidget(
                initialLeftEarData: leftEarData,
                initialRightEarData: rightEarData,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First check that the initial audiogram is shown
      expect(find.byType(Audiogram), findsOneWidget);

      // Find and tap the update button to change the data
      final updateButton = find.text('Update Data');
      expect(updateButton, findsOneWidget);

      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      // The audiogram should still exist with the new data
      expect(find.byType(Audiogram), findsOneWidget);
    });

    testWidgets('handles empty data gracefully', (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build with empty data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Audiogram(
                leftEarData: {},
                rightEarData: {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without crashing
      expect(find.byType(Audiogram), findsOneWidget);

      // We should still have the CustomPaint widget that renders the graph
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });
  });
}

// Helper widget for testing Audiogram updates
class _AudiogramTestWidget extends StatefulWidget {
  final Map<String, double> initialLeftEarData;
  final Map<String, double> initialRightEarData;

  const _AudiogramTestWidget({
    required this.initialLeftEarData,
    required this.initialRightEarData,
  });

  @override
  _AudiogramTestWidgetState createState() => _AudiogramTestWidgetState();
}

class _AudiogramTestWidgetState extends State<_AudiogramTestWidget> {
  late Map<String, double> leftEarData;
  late Map<String, double> rightEarData;

  @override
  void initState() {
    super.initState();
    leftEarData = Map.from(widget.initialLeftEarData);
    rightEarData = Map.from(widget.initialRightEarData);
  }

  void _updateData() {
    setState(() {
      // Increase all values by 10dB
      leftEarData =
          leftEarData.map((key, value) => MapEntry(key, value + 10.0));
      rightEarData =
          rightEarData.map((key, value) => MapEntry(key, value + 10.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Audiogram(
          leftEarData: leftEarData,
          rightEarData: rightEarData,
        ),
        ElevatedButton(
          onPressed: _updateData,
          child: const Text('Update Data'),
        ),
      ],
    );
  }
}
