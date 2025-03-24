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
        final currentTest = soundTests[activeSoundTestId]!;
        _hasTestBeenTaken = currentTest.soundTestData.values.any((v) => v > 0);
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

  Widget _buildInstructions() {
    return const Column(
      children: [
        Text(
          'Some instructions before starting the test:',
          style: TextStyle(fontSize: 20),
        ),
        ListBody(
          children: [
            ListTile(
              leading: Icon(Icons.keyboard_arrow_right),
              title: Text('Sit in a quiet environment.'),
            ),
            ListTile(
              leading: Icon(Icons.keyboard_arrow_right),
              title: Text('Wear your headphones correctly and comfortably.'),
            ),
            ListTile(
              leading: Icon(Icons.keyboard_arrow_right),
              title: Text('Press the button when you hear the sound.'),
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
            _buildTestResultRow('Left Band 1', getBandValue('L_band_1_dB')),
            _buildTestResultRow('Left Band 2', getBandValue('L_band_2_dB')),
            _buildTestResultRow('Left Band 3', getBandValue('L_band_3_dB')),
            _buildTestResultRow('Left Band 4', getBandValue('L_band_4_dB')),
            _buildTestResultRow('Left Band 5', getBandValue('L_band_5_dB')),
            _buildTestResultRow('Right Band 1', getBandValue('R_band_1_dB')),
            _buildTestResultRow('Right Band 2', getBandValue('R_band_2_dB')),
            _buildTestResultRow('Right Band 3', getBandValue('R_band_3_dB')),
            _buildTestResultRow('Right Band 4', getBandValue('R_band_4_dB')),
            _buildTestResultRow('Right Band 5', getBandValue('R_band_5_dB')),
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
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(237, 212, 254, 1.00),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentTest = activeSoundTestId != null
        ? widget.soundTestProvider.soundTests[activeSoundTestId]
        : null;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
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
                      if (!_hasTestBeenTaken && activeSoundTestId == null) {
                        final newId = 'soundTest_${DateTime.now().millisecondsSinceEpoch}';
                        final newSoundTest = SoundTest.defaultTest(newId);
                        await widget.soundTestProvider.createSoundTest(newSoundTest);
                      }

                      if (context.mounted && activeSoundTestId != null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestPage(
                              soundTestId: activeSoundTestId!,
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
                if (!_hasTestBeenTaken)
                  _buildInstructions(),
                if (_hasTestBeenTaken && currentTest != null)
                  _buildTestResults(currentTest),
              ],
            ),
          ),
        ],
      ),
    );
  }
}