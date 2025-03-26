import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bluetooth_provider.dart';

class HeadphoneInfoBanner extends StatelessWidget {
  const HeadphoneInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, child) {
        final isConnected = bluetoothProvider.isDeviceConnected;
        final deviceName = bluetoothProvider.connectedDeviceName;
        final batteryLevel = bluetoothProvider.batteryLevel;

        if (!isConnected) {
          return Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bluetooth_disabled,
                  color: Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No headphones connected',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Define battery icon and color based on level
        IconData batteryIcon;
        Color batteryColor;

        if (batteryLevel == null) {
          batteryIcon = Icons.battery_unknown;
          batteryColor = Colors.grey;
        } else if (batteryLevel <= 15) {
          batteryIcon = Icons.battery_alert;
          batteryColor = Colors.red;
        } else if (batteryLevel <= 30) {
          batteryIcon = Icons.battery_2_bar;
          batteryColor = Colors.orange;
        } else if (batteryLevel <= 60) {
          batteryIcon = Icons.battery_4_bar;
          batteryColor = Colors.yellow;
        } else if (batteryLevel <= 80) {
          batteryIcon = Icons.battery_5_bar;
          batteryColor = Colors.lightGreen;
        } else {
          batteryIcon = Icons.battery_full;
          batteryColor = Colors.green;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bluetooth_connected,
                color: theme.colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  deviceName,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (batteryLevel != null) ...[
                Icon(
                  batteryIcon,
                  color: batteryColor,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '$batteryLevel%',
                  style: TextStyle(
                    color: batteryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
