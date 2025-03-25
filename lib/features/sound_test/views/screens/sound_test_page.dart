import 'package:flutter/material.dart';
import 'package:projects/features/sound_test/views/screens/test_page.dart';
import '../../providers/sound_test_provider.dart';
import '../../models/sound_test.dart';

class SoundTestPage extends StatefulWidget {
  final SoundTestProvider soundTestProvider;

  const SoundTestPage({
    super.key,
    required this.soundTestProvider,
  });

  @override
  State<SoundTestPage> createState() => _SoundTestPageState();
}

class _SoundTestPageState extends State<SoundTestPage> {
  String? activeSoundTestId;
  bool _hasTestBeenTaken = false;
  bool _isResetting = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    try {
      await widget.soundTestProvider.fetchSoundTests();
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _updateState();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.soundTestProvider.removeListener(_updateState);
    widget.soundTestProvider.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.soundTestProvider.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (!mounted) return;

    final soundTests = widget.soundTestProvider.soundTests;
    setState(() {
      if (soundTests.isEmpty) {
        _hasTestBeenTaken = false;
        activeSoundTestId = null;
      } else {
        activeSoundTestId =
            widget.soundTestProvider.activeSoundTestId ?? soundTests.keys.first;
        final currentTest = soundTests[activeSoundTestId!];
        _hasTestBeenTaken = currentTest != null &&
            currentTest.soundTestData.values.any((v) => v > 0);
      }
    });
  }

  Future<void> _showTestCompletionDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test Completed'),
          content: const Text(
            'Your hearing test has been completed successfully. The results have been saved.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showValuesSavedDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Values Saved'),
          content: const Text('Your test values have been saved successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showResetConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Reset'),
              content: const Text(
                  'Are you sure you want to reset to default values?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Reset'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String soundTestName) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content:
                  Text('Are you sure you want to delete "$soundTestName"?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _resetAudioProfile() async {
    if (activeSoundTestId == null) return;

    final shouldReset = await _showResetConfirmationDialog(context);
    if (!shouldReset) return;

    setState(() => _isResetting = true);

    try {
      await widget.soundTestProvider.resetSoundTest(activeSoundTestId!);
      if (mounted) {
        await _showValuesSavedDialog(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  Future<void> _startNewTest(BuildContext context) async {
    final soundTestId = activeSoundTestId ??
        'soundTest_${DateTime.now().millisecondsSinceEpoch}';

    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestPage(
            soundTestId: soundTestId,
            soundTestName: 'Audio Profile',
            soundTestProvider: widget.soundTestProvider,
          ),
        ),
      );

      if (context.mounted) {
        await widget.soundTestProvider.fetchSoundTests();
        setState(() {
          activeSoundTestId = soundTestId;
        });
      }
    }
  }

  void _resetToBaseline() {
    final defaultTest = SoundTest.defaultTest(activeSoundTestId!);
    widget.soundTestProvider.updateSoundTest(defaultTest);
    setState(() {});
  }

  void _retakeTest() {
    _startNewTest(context);
  }

  Widget _buildInstructions(Color textColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Some instructions before starting the test:',
            style: TextStyle(
                fontSize: 20, color: textColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListBody(
            children: [
              ListTile(
                leading: Icon(Icons.keyboard_arrow_right, color: iconColor),
                title: Text(
                  'Sit in a quiet environment.',
                  style: TextStyle(color: textColor),
                ),
              ),
              ListTile(
                leading: Icon(Icons.keyboard_arrow_right, color: iconColor),
                title: Text(
                  'Wear your headphones correctly and comfortably.',
                  style: TextStyle(color: textColor),
                ),
              ),
              ListTile(
                leading: Icon(Icons.keyboard_arrow_right, color: iconColor),
                title: Text(
                  'Press the button when you hear the sound.',
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudiogramChart() {
    final theme = Theme.of(context);

    // Get current sound test data
    if (activeSoundTestId == null ||
        !widget.soundTestProvider.soundTests.containsKey(activeSoundTestId)) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No test data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final soundTest = widget.soundTestProvider.soundTests[activeSoundTestId]!;
    final soundTestData = soundTest.soundTestData;

    // Frequencies to display
    final frequencies = [
      '250Hz',
      '500Hz',
      '1000Hz',
      '2000Hz',
      '4000Hz',
      '8000Hz'
    ];

    // Get left and right ear data
    final leftEarData = [
      soundTestData['L_user_250Hz_dB'] ?? 0.0,
      soundTestData['L_user_500Hz_dB'] ?? 0.0,
      soundTestData['L_user_1000Hz_dB'] ?? 0.0,
      soundTestData['L_user_2000Hz_dB'] ?? 0.0,
      soundTestData['L_user_4000Hz_dB'] ?? 0.0,
      soundTestData['L_user_8000Hz_dB'] ?? 0.0,
    ];

    final rightEarData = [
      soundTestData['R_user_250Hz_dB'] ?? 0.0,
      soundTestData['R_user_500Hz_dB'] ?? 0.0,
      soundTestData['R_user_1000Hz_dB'] ?? 0.0,
      soundTestData['R_user_2000Hz_dB'] ?? 0.0,
      soundTestData['R_user_4000Hz_dB'] ?? 0.0,
      soundTestData['R_user_8000Hz_dB'] ?? 0.0,
    ];

    // Transform values from volume (0-1) to dB (approximate)
    List<double> transformVolumeToDB(List<double> volumes) {
      return volumes.map<double>((volume) {
        if (volume <= 0) return 0;
        // Convert volume (0-1) to dB scale (roughly -60 to 0)
        // Lower volume = higher dB value (more hearing loss)
        return (1 - volume) * 60;
      }).toList();
    }

    final leftEarDBValues = transformVolumeToDB(leftEarData);
    final rightEarDBValues = transformVolumeToDB(rightEarData);

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Left Ear'),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Right Ear'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Audiogram chart
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                frequencies.length,
                (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Left ear bar
                          Container(
                            height: (leftEarDBValues[index] / 60) * 120,
                            width: 8,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Right ear bar
                          Container(
                            height: (rightEarDBValues[index] / 60) * 120,
                            width: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Frequency label
                          Text(
                            frequencies[index],
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults() {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Hearing Test Results',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Audiogram chart
          _buildAudiogramChart(),

          const SizedBox(height: 16),

          // Buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reset Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: _resetToBaseline,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Reset to Baseline',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Retake Test Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ElevatedButton(
                    onPressed: _retakeTest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Retake Test',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text(
          'Hearing Test',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Show audiogram if a test exists
                if (activeSoundTestId != null) ...[
                  Text(
                    'Your Hearing Profile',
                    style: TextStyle(
                      fontSize: (screenWidth * 0.06).clamp(20.0, 32.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    height: (screenHeight * 0.35).clamp(200.0, 350.0),
                    child: _buildAudiogramChart(),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.02),
                          child: ElevatedButton(
                            onPressed: _resetToBaseline,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenHeight * 0.02,
                              ),
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Reset to Baseline',
                              style: TextStyle(
                                fontSize:
                                    (screenWidth * 0.04).clamp(14.0, 20.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.02),
                          child: ElevatedButton(
                            onPressed: _retakeTest,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenHeight * 0.02,
                              ),
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Retake Test',
                              style: TextStyle(
                                fontSize:
                                    (screenWidth * 0.04).clamp(14.0, 20.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Initial state - no test taken yet
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.1,
                      horizontal: screenWidth * 0.06,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Take a Hearing Test',
                          style: TextStyle(
                            fontSize: (screenWidth * 0.06).clamp(20.0, 32.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Start your hearing test to create a personalized audio profile.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        ElevatedButton(
                          onPressed: () => _startNewTest(context),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                              vertical: screenHeight * 0.02,
                            ),
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Start Test',
                            style: TextStyle(
                              fontSize: (screenWidth * 0.05).clamp(16.0, 24.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
