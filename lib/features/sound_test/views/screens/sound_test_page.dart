import 'package:flutter/material.dart';
import 'package:projects/features/sound_test/views/screens/test_page.dart';
import '../../providers/sound_test_provider.dart';
import '../../models/sound_test.dart';
import '../../widgets/audiogram.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/bluetooth/services/ble_data_service.dart';
import '../../../../features/bluetooth/services/bluetooth_file_service.dart';
import '../../../../features/bluetooth/providers/bluetooth_provider.dart';
import 'package:provider/provider.dart';

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
  final BLEDataService _bleDataService = BLEDataService();
  final BluetoothFileService _btFileService = BluetoothFileService();

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
    final appLocalizations = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.translate('test_completed')),
          content: Text(
            appLocalizations.translate('test_completed_message'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appLocalizations.translate('ok')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showValuesSavedDialog(BuildContext context) async {
    final appLocalizations = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.translate('values_saved')),
          content: Text(appLocalizations.translate('values_saved_message')),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appLocalizations.translate('ok')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendHearingTestData({bool silent = true}) async {
    if (activeSoundTestId == null) return;

    final soundTest =
        widget.soundTestProvider.getSoundTestById(activeSoundTestId!);
    if (soundTest == null) return;

    final bluetoothProvider =
        Provider.of<BluetoothProvider>(context, listen: false);

    // Only send if device is connected
    if (bluetoothProvider.isDeviceConnected) {
      try {
        // NOTE: The BLE service sends data silently already, but the notification
        // is coming from the platform code, not from this method
        await _bleDataService.sendHearingTestData(soundTest);

        // We'll handle notifications here instead
        if (!silent && mounted) {
          // Show notification only if not in silent mode
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context).translate('sent_to_device')),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        // Silently log error without showing to user
        print('Error sending hearing test data: $e');
      }
    }
  }

  Future<void> _shareViaBluetoothFile() async {
    if (activeSoundTestId == null) return;

    final soundTest =
        widget.soundTestProvider.getSoundTestById(activeSoundTestId!);
    if (soundTest == null) return;

    try {
      final success = await _btFileService.sendHearingTestFile(soundTest);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('file_sent_successfully')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error sharing via Bluetooth: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context).translate('file_send_failed')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<bool> _showResetConfirmationDialog(BuildContext context) async {
    final appLocalizations = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(appLocalizations.translate('confirm_reset')),
              content:
                  Text(appLocalizations.translate('confirm_reset_message')),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(appLocalizations.translate('cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(appLocalizations.translate('reset')),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String soundTestName) async {
    final appLocalizations = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(appLocalizations.translate('confirm_delete')),
              content: Text(
                  '${appLocalizations.translate('confirm_delete_message')} "$soundTestName"?'),
              actions: <Widget>[
                TextButton(
                  child: Text(appLocalizations.translate('cancel')),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(appLocalizations.translate('delete')),
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
        // No dialog needed - silently reset

        // Send reset data to device silently
        _sendHearingTestData(silent: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  Future<void> _startNewTest(BuildContext context) async {
    final appLocalizations = AppLocalizations.of(context);
    final soundTestId = activeSoundTestId ??
        'soundTest_${DateTime.now().millisecondsSinceEpoch}';

    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestPage(
            soundTestId: soundTestId,
            soundTestName: appLocalizations.translate('audio_profile'),
            soundTestProvider: widget.soundTestProvider,
          ),
        ),
      );

      if (context.mounted) {
        await widget.soundTestProvider.fetchSoundTests();
        setState(() {
          activeSoundTestId = soundTestId;
        });

        // Add a brief delay to prevent resource conflicts with audio assets
        await Future.delayed(const Duration(milliseconds: 500));

        // Send the updated hearing test data
        _sendHearingTestData();
      }
    }
  }

  void _resetToBaseline() {
    final defaultTest =
        SoundTest.defaultTest(activeSoundTestId!, context: context);
    widget.soundTestProvider.updateSoundTest(defaultTest);
    setState(() {});

    // Send reset data to device silently
    _sendHearingTestData(silent: true);

    // Show a simple notification without mentioning data being sent
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('reset_successful')),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _retakeTest() {
    _startNewTest(context);
  }

  Widget _buildAudiogramSection() {
    final appLocalizations = AppLocalizations.of(context);
    final soundTest =
        widget.soundTestProvider.getSoundTestById(activeSoundTestId!);
    if (soundTest == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.translate('your_audiogram'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.translate('audiogram_description'),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Audiogram(
              leftEarData: soundTest.soundTestData,
              rightEarData: soundTest.soundTestData,
              leftEarLabel: appLocalizations.translate('left_ear'),
              rightEarLabel: appLocalizations.translate('right_ear'),
              frequencyLabel: appLocalizations.translate('frequency'),
              hearingLevelLabel: appLocalizations.translate('hearing_level'),
              normalHearingLabel: appLocalizations.translate('normal_hearing'),
              mildLossLabel: appLocalizations.translate('mild_loss'),
              moderateLossLabel: appLocalizations.translate('moderate_loss'),
              severeLossLabel: appLocalizations.translate('severe_loss'),
              profoundLossLabel: appLocalizations.translate('profound_loss'),
            ),
            const SizedBox(height: 16),
            Text(
              'Note: Values displayed in dB HL (Hearing Level)',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetToBaseline,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          appLocalizations.translate('reset_to_baseline'),
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _retakeTest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          appLocalizations.translate('retake_test'),
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareViaBluetoothFile,
                icon: const Icon(Icons.share, size: 18),
                label: Text(
                  appLocalizations.translate('share_via_bluetooth'),
                  style: const TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('hearing_test')),
      ),
      body: activeSoundTestId != null
          ? _buildAudiogramSection()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.hearing,
                          size: 48,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          appLocalizations.translate('welcome_hearing_test'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          appLocalizations
                              .translate('take_hearing_test_message'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _startNewTest(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              appLocalizations.translate('start_test'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
