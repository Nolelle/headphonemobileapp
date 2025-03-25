import 'package:flutter/material.dart';
import 'package:projects/features/sound_test/views/screens/test_page.dart';
import '../../providers/sound_test_provider.dart';

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

          // Audiogram placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: Text(
                'Audiogram will be displayed here',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _resetAudioProfile,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Reset to Default Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black87;

    if (_isInitializing) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Sound Test'),
      ),
      body: _isResetting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: ElevatedButton(
                        onPressed: () async {
                          // Determine if we're creating or updating
                          final audioProfiles =
                              widget.soundTestProvider.soundTests;
                          String soundTestId;
                          String buttonText;

                          if (audioProfiles.isEmpty) {
                            // Create new profile
                            soundTestId =
                                'soundTest_${DateTime.now().millisecondsSinceEpoch}';
                            buttonText = "New Audio Profile";
                          } else {
                            // Update existing profile
                            soundTestId = audioProfiles.keys.first;
                            buttonText = "Audio Profile";
                          }

                          if (context.mounted) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestPage(
                                  soundTestId: soundTestId,
                                  soundTestName: buttonText,
                                  soundTestProvider: widget.soundTestProvider,
                                ),
                              ),
                            );

                            if (context.mounted) {
                              await widget.soundTestProvider.fetchSoundTests();

                              // Show completion dialog if test was completed
                              if (result == true) {
                                await _showTestCompletionDialog(context);
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          minimumSize: const Size(double.infinity, 60),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _hasTestBeenTaken
                              ? "Retake Hearing Test"
                              : "Begin Hearing Test",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Only show instructions if no test has been taken
                    if (!_hasTestBeenTaken)
                      _buildInstructions(textColor, iconColor),

                    // Show test results if test has been taken
                    if (_hasTestBeenTaken && activeSoundTestId != null)
                      _buildTestResults(),
                  ],
                ),
              ),
            ),
    );
  }
}
