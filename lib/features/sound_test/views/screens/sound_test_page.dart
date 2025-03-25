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
        activeSoundTestId = widget.soundTestProvider.activeSoundTestId ?? soundTests.keys.first;
        final currentTest = soundTests[activeSoundTestId!];
        _hasTestBeenTaken = currentTest != null && 
            currentTest.soundTestData.values.any((v) => v > 0);
      }
    });
  }

  Future<bool> _showResetConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text('Are you sure you want to reset to default values?'),
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
    ) ?? false;
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
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  Widget _buildInstructions(Color textColor, Color iconColor) {
    return Column(
      children: [
        Text(
          'Some instructions before starting the test:',
          style: TextStyle(fontSize: 20, color: textColor),
        ),
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
    );
  }

  Widget _buildTestResults(SoundTest soundTest) {
    double getBandValue(String key) => soundTest.soundTestData[key] ?? 0.0;

    return Column(
      children: [
        const Text(
          'Your Test Results:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            _buildTestResultRow('Left Band 1', getBandValue('L_user_250Hz_dB')),
            _buildTestResultRow('Left Band 2', getBandValue('L_user_500Hz_dB')),
            _buildTestResultRow('Left Band 3', getBandValue('L_user_1000Hz_dB')),
            _buildTestResultRow('Left Band 4', getBandValue('L_user_2000Hz_dB')),
            _buildTestResultRow('Left Band 5', getBandValue('L_user_4000Hz_dB')),
            _buildTestResultRow('Left Band 6', getBandValue('L_user_8000Hz_dB')),
            _buildTestResultRow('Right Band 1', getBandValue('R_user_250Hz_dB')),
            _buildTestResultRow('Right Band 2', getBandValue('R_user_500Hz_dB')),
            _buildTestResultRow('Right Band 3', getBandValue('R_user_1000Hz_dB')),
            _buildTestResultRow('Right Band 4', getBandValue('R_user_2000Hz_dB')),
            _buildTestResultRow('Right Band 5', getBandValue('R_user_4000Hz_dB')),
            _buildTestResultRow('Right Band 6', getBandValue('R_user_8000Hz_dB')),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _resetAudioProfile,
          child: const Text('Reset Profile'),
        ),
      ],
    );
  }

  Widget _buildTestResultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            '${value.toStringAsFixed(2)} dB',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                          onPressed: () async {
                            final audioProfileCount =
                                widget.soundTestProvider.soundTests.length;
                            if (audioProfileCount >= 3) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'You can only have a maximum of 3 audio profiles!'),
                                ),
                              );
                              return;
                            }

                            final newId =
                                'soundTest_${DateTime.now().millisecondsSinceEpoch}';
                            final newSoundTest = SoundTest(
                              id: newId,
                              name: 'Audio Profile #${audioProfileCount + 1}',
                              dateCreated: DateTime.now(),
                              soundTestData: {
                                'L_user_250Hz_dB': 0.0,
                                'L_user_500Hz_dB': 0.0,
                                'L_user_1000Hz_dB': 0.0,
                                'L_user_2000Hz_dB': 0.0,
                                'L_user_4000Hz_dB': 0.0,
                                'L_user_8000Hz_dB': 0.0,
                                'R_user_250Hz_dB': 0.0,
                                'R_user_500Hz_dB': 0.0,
                                'R_user_1000Hz_dB': 0.0,
                                'R_user_2000Hz_dB': 0.0,
                                'R_user_4000Hz_dB': 0.0,
                                'R_user_8000Hz_dB': 0.0,
                              },
                              icon: Icons.music_note,
                            );

                            await widget.soundTestProvider
                                .createSoundTest(newSoundTest);

                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TestPage(
                                    soundTestId: newId,
                                    soundTestName:
                                        'Audio Profile #${audioProfileCount + 1}',
                                    soundTestProvider: widget.soundTestProvider,
                                  ),
                                ),
                              );
                              if (context.mounted) {
                                await widget.soundTestProvider.fetchSoundTests();
                              }
                            }
                          },
                          child: const Text('Begin Sound Test'),
                        ),
                      ),
                      _buildInstructions(textColor, iconColor),
                      // Show test results if available for the active profile
                      if (_hasTestBeenTaken && activeSoundTestId != null)
                        _buildTestResults(widget.soundTestProvider.soundTests[activeSoundTestId!]!),
                    ],
                  ),
                ),
                // Title of 'Audio Presets' with counter
                Consumer<SoundTestProvider>(builder: (context, provider, child) {
                  final audioProfileCount = provider.soundTests.length;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Audio Profiles: $audioProfileCount/3',
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
                // The audio profiles
                Expanded(
                  child: Consumer<SoundTestProvider>(
                    builder: (context, provider, child) {
                      final soundTests = provider.soundTests.values.toList();
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: soundTests.length,
                        itemBuilder: (context, index) {
                          final soundTest = soundTests[index];
                          final isActive = soundTest.id == provider.activeSoundTestId;

                          return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          activeSoundTestId = soundTest.id;
                                        });

                                        provider.setActiveSoundTest(soundTest.id);

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '${soundTest.name} Successfully Applied!'),
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isActive
                                            ? theme.colorScheme.secondary
                                            : theme.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        minimumSize: const Size(double.infinity, 50),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                              0, 0, 10, 0),
                                                      child: Icon(
                                                        soundTest.icon,
                                                        color: Colors.white,
                                                        size: 25,
                                                      ),
                                                    ),
                                                    Text(
                                                      soundTest.name,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ]),
                                              IconButton(
                                                onPressed: () async {
                                                  final shouldDelete =
                                                      await _showDeleteConfirmationDialog(
                                                          context, soundTest.name);
                                                  if (shouldDelete) {
                                                    provider.deleteSoundTest(
                                                        soundTest.id);
                                                    setState(() {
                                                      activeSoundTestId = null;
                                                    });
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            '${soundTest.name} deleted successfully!'),
                                                      ),
                                                    );
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.delete_forever,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}