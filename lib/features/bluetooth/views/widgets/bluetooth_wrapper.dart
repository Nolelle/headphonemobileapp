// File: lib/features/bluetooth/views/widgets/bluetooth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bluetooth_provider.dart';
import 'package:flutter/services.dart';
import '../../../bluetooth/platform/bluetooth_platform.dart';
import '../../../../shared/widgets/app_splash_screen.dart';
import '../../../../features/settings/providers/theme_provider.dart';

class BluetoothWrapper extends StatefulWidget {
  final Widget child;

  const BluetoothWrapper({super.key, required this.child});

  @override
  State<BluetoothWrapper> createState() => _BluetoothWrapperState();
}

class _BluetoothWrapperState extends State<BluetoothWrapper>
    with SingleTickerProviderStateMixin {
  bool _isAttemptingConnection = false;
  String _statusMessage = '';
  bool _showSplashScreen = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start the transition after a delay
    Future.delayed(const Duration(seconds: 4), () {
      // Only hide splash if mounted
      if (mounted) {
        _animationController.forward().then((_) {
          setState(() {
            _showSplashScreen = false;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, _) {
        // Show splash screen during initial load
        if (_showSplashScreen) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: AppSplashScreen(isDarkMode: isDarkMode),
          );
        }

        // Show connection screen if not connected
        if (!bluetoothProvider.isDeviceConnected) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text('Connect Bluetooth'),
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bluetooth_searching,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Please connect your Bluetooth headphones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'To use this app, you need to connect your Bluetooth headphones',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _isAttemptingConnection
                          ? _buildConnectionProgress()
                          : _buildConnectionButtons(bluetoothProvider),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Show main app if connected
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }

  Widget _buildConnectionProgress() {
    return Column(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _statusMessage.isNotEmpty
              ? _statusMessage
              : 'Checking for connected devices...',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isAttemptingConnection = false;
              _statusMessage = '';
            });
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildConnectionButtons(BluetoothProvider bluetoothProvider) {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings_bluetooth),
                  label: const Text('Open Bluetooth Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () async {
                    try {
                      // Simply open the Bluetooth settings without additional logic
                      const MethodChannel settingsChannel =
                          MethodChannel('com.headphonemobileapp/settings');
                      await settingsChannel
                          .invokeMethod('openBluetoothSettings');
                    } catch (e) {
                      print('Error opening Bluetooth settings: $e');

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error opening Bluetooth settings: $e'),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check For Devices'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onPressed: () => _checkForDevices(bluetoothProvider),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Developer Options',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.developer_mode),
                  label: const Text('Bypass Check'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  onPressed: () {
                    bluetoothProvider.setBypassBluetoothCheck(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bluetooth check bypassed',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkForDevices(BluetoothProvider bluetoothProvider) async {
    setState(() {
      _isAttemptingConnection = true;
      _statusMessage = 'Checking for connected devices...';
    });

    try {
      // First, verify Bluetooth is enabled
      final isBluetoothEnabled = await BluetoothPlatform.isBluetoothEnabled();
      if (!isBluetoothEnabled) {
        setState(() {
          _statusMessage = 'Bluetooth is not enabled. Please enable Bluetooth.';
        });
        await Future.delayed(const Duration(seconds: 2));
        return;
      }

      // Check connection status using platform methods directly
      setState(() {
        _statusMessage = 'Checking system connections...';
      });

      // Try to get connected device from platform layer
      final connectedDevice = await BluetoothPlatform.getConnectedDevice();

      // Check audio status too
      final isAudioConnected = await BluetoothPlatform.isAudioDeviceConnected();
      final audioType = await BluetoothPlatform.getBluetoothAudioType();

      // Update the provider with this info
      if (connectedDevice != null && isAudioConnected) {
        // Use the provider's public method to update the connection
        await bluetoothProvider.updateConnectionFromDevice(
            connectedDevice, audioType);

        setState(() {
          _statusMessage = 'Found connected device: ${connectedDevice.name}';
        });
      } else {
        setState(() {
          _statusMessage = 'No connected devices found';
        });
      }

      // For robustness, add a delay then check one more time using the provider's method
      await Future.delayed(const Duration(seconds: 1));
      await bluetoothProvider.checkBluetoothConnection();

      // Final status message
      setState(() {
        _statusMessage = bluetoothProvider.isDeviceConnected
            ? 'Connected to: ${bluetoothProvider.connectedDeviceName}'
            : 'No connected devices found';
      });

      // Wait a moment to show the result
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking devices: $e';
      });
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      if (mounted) {
        setState(() {
          _isAttemptingConnection = false;
          _statusMessage = '';
        });
      }
    }
  }
}
