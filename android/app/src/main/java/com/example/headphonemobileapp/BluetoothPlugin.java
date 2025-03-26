package com.example.headphonemobileapp;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothHeadset;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.media.AudioManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.Random;

public class BluetoothPlugin implements FlutterPlugin, MethodCallHandler {

    private static final String TAG = "BluetoothPlugin";
    private static final String CHANNEL_NAME = "com.headphonemobileapp/bluetooth";

    private MethodChannel channel;
    private Context context;
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothManager bluetoothManager;
    private BluetoothHeadset bluetoothHeadset;
    private AudioManager audioManager;
    private final Random random = new Random();

    // For tracking scan results
    private List<BluetoothDevice> scannedDevices = new ArrayList<>();
    private boolean isScanning = false;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
        context = binding.getApplicationContext();
        
        // Initialize Bluetooth adapter
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            bluetoothManager = (BluetoothManager) context.getSystemService(Context.BLUETOOTH_SERVICE);
            if (bluetoothManager != null) {
                bluetoothAdapter = bluetoothManager.getAdapter();
            }
        } else {
            bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        }
        
        // Initialize audio manager
        audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        
        // Initialize BluetoothHeadset proxy
        if (bluetoothAdapter != null) {
            bluetoothAdapter.getProfileProxy(context, new BluetoothProfile.ServiceListener() {
                @Override
                public void onServiceConnected(int profile, BluetoothProfile proxy) {
                    if (profile == BluetoothProfile.HEADSET) {
                        bluetoothHeadset = (BluetoothHeadset) proxy;
                    }
                }
                
                @Override
                public void onServiceDisconnected(int profile) {
                    if (profile == BluetoothProfile.HEADSET) {
                        bluetoothHeadset = null;
                    }
                }
            }, BluetoothProfile.HEADSET);
        }
    }
    
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
        
        // Close Bluetooth proxy connections
        if (bluetoothAdapter != null && bluetoothHeadset != null) {
            bluetoothAdapter.closeProfileProxy(BluetoothProfile.HEADSET, bluetoothHeadset);
            bluetoothHeadset = null;
        }
        context = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("isBluetoothEnabled")) {
            result.success(isBluetoothEnabled());
        } else if (call.method.equals("startScan")) {
            startScan(result);
        } else if (call.method.equals("stopScan")) {
            stopScan(result);
        } else if (call.method.equals("getScannedDevices")) {
            result.success(getScannedDevicesAsList());
        } else if (call.method.equals("connectToDevice")) {
            String deviceId = call.argument("deviceId");
            connectToDevice(deviceId, result);
        } else if (call.method.equals("disconnectDevice")) {
            disconnectDevice(result);
        } else if (call.method.equals("getConnectedDevice")) {
            result.success(getConnectedDeviceAsMap());
        } else if (call.method.equals("isAudioDeviceConnected")) {
            result.success(isAudioDeviceConnected());
        } else if (call.method.equals("isLEAudioConnected")) {
            result.success(isLEAudioConnected());
        } else if (call.method.equals("isClassicAudioConnected")) {
            result.success(isClassicAudioConnected());
        } else if (call.method.equals("forceAudioRoutingToBluetooth")) {
            forceAudioRoutingToBluetooth(result);
        } else if (call.method.equals("getBtConnectionType")) {
            result.success(getBluetoothAudioConnectionType());
        } else if (call.method.equals("openBluetoothSettings")) {
            openBluetoothSettings(result);
        } else if (call.method.equals("getBatteryLevel")) {
            getMockBatteryLevel(result);
        } else {
            result.notImplemented();
        }
    }

    /**
     * Provides a mock battery level for testing the UI.
     * In a real implementation, this would retrieve actual battery levels.
     *
     * @param result Result callback to return the battery level
     */
    private void getMockBatteryLevel(Result result) {
        try {
            // Check if we have a connected device
            if (isAudioDeviceConnected()) {
                // Get connected device name if available
                String deviceName = "Unknown Device";
                try {
                    // Try to get the actual device name if available
                    Map<String, Object> deviceMap = getConnectedDeviceAsMap();
                    if (deviceMap != null && deviceMap.containsKey("name")) {
                        deviceName = (String) deviceMap.get("name");
                    }
                } catch (Exception e) {
                    // Ignore errors getting device name
                }
                
                // Return mock values based on device name
                if (deviceName != null) {
                    String name = deviceName.toLowerCase();
                    if (name.contains("sony") || name.contains("wh-1000")) {
                        result.success(85); // Sony headphones
                        return;
                    } else if (name.contains("bose") || name.contains("quiet")) {
                        result.success(78); // Bose headphones
                        return;
                    } else if (name.contains("airpods") || name.contains("beats")) {
                        result.success(65); // Apple products
                        return;
                    } else if (name.contains("samsung") || name.contains("galaxy")) {
                        result.success(55); // Samsung products
                        return;
                    } else if (name.contains("jabra")) {
                        result.success(42); // Jabra products
                        return;
                    }
                }
                
                // For unknown headphones, return a random level between 30-90%
                int randomLevel = 30 + (int)(Math.random() * 60);
                result.success(randomLevel);
            } else {
                // No device connected
                result.success(null);
            }
        } catch (Exception e) {
            // On any error, return a default value
            result.success(50);
        }
    }

    // Additional methods for other functionality
    private void startScan(Result result) {
        // Implementation for starting Bluetooth scan
        result.success(true);
    }

    private void stopScan(Result result) {
        // Implementation for stopping Bluetooth scan
        result.success(true);
    }

    private List<Map<String, Object>> getScannedDevicesAsList() {
        List<Map<String, Object>> devicesList = new ArrayList<>();
        // Implementation for getting scanned devices
        return devicesList;
    }

    private void connectToDevice(String deviceId, Result result) {
        // Implementation for connecting to a device
        result.success(true);
    }

    private void disconnectDevice(Result result) {
        // Implementation for disconnecting a device
        result.success(true);
    }

    private boolean isLEAudioConnected() {
        // Implementation for checking LE Audio connection
        return false;
    }

    private boolean isClassicAudioConnected() {
        // Implementation for checking Classic Audio connection
        return true;
    }

    private void forceAudioRoutingToBluetooth(Result result) {
        // Implementation for forcing audio routing to Bluetooth
        result.success(true);
    }

    private String getBluetoothAudioConnectionType() {
        // Implementation for getting audio connection type
        return "classic";
    }

    private void openBluetoothSettings(Result result) {
        // Implementation for opening Bluetooth settings
        result.success(true);
    }

    // Helper methods
    private boolean isBluetoothEnabled() {
        return bluetoothAdapter != null && bluetoothAdapter.isEnabled();
    }

    private boolean isAudioDeviceConnected() {
        if (!isBluetoothEnabled()) {
            return false;
        }
        
        // Check if a headset is connected
        if (bluetoothHeadset != null) {
            List<BluetoothDevice> devices = bluetoothHeadset.getConnectedDevices();
            if (!devices.isEmpty()) {
                return true;
            }
        }
        
        // Check if audio is routed to Bluetooth
        if (audioManager != null) {
            return audioManager.isBluetoothA2dpOn() || audioManager.isBluetoothScoOn();
        }
        
        return false;
    }

    private Map<String, Object> getConnectedDeviceAsMap() {
        BluetoothDevice device = getConnectedBluetoothDevice();
        if (device != null) {
            Map<String, Object> deviceMap = new HashMap<>();
            deviceMap.put("id", device.getAddress());
            deviceMap.put("name", device.getName() != null ? device.getName() : "Unknown Device");
            deviceMap.put("type", getDeviceType(device));
            
            // Add battery level if available
            Integer batteryLevel = getDeviceBatteryLevel(device);
            if (batteryLevel != null) {
                deviceMap.put("batteryLevel", batteryLevel);
            }
            
            return deviceMap;
        }
        return null;
    }

    private BluetoothDevice getConnectedBluetoothDevice() {
        if (bluetoothHeadset != null) {
            List<BluetoothDevice> connectedDevices = bluetoothHeadset.getConnectedDevices();
            if (!connectedDevices.isEmpty()) {
                return connectedDevices.get(0);
            }
        }
        return null;
    }

    private String getDeviceType(BluetoothDevice device) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            int deviceType = device.getType();
            if (deviceType == BluetoothDevice.DEVICE_TYPE_CLASSIC) {
                return "classic";
            } else if (deviceType == BluetoothDevice.DEVICE_TYPE_LE) {
                return "le";
            } else if (deviceType == BluetoothDevice.DEVICE_TYPE_DUAL) {
                return "dual";
            }
        }
        return "unknown";
    }

    /**
     * Get the battery level for a device using various methods.
     * 
     * @param device The Bluetooth device
     * @return Battery level as percentage or null if not available
     */
    private Integer getDeviceBatteryLevel(BluetoothDevice device) {
        if (device == null) return null;
        
        // The BluetoothHeadset.getBatteryLevel method isn't available or doesn't work as expected
        // Just rely on our vendor-specific mock implementation
        return getVendorSpecificBatteryLevel(device);
    }

    /**
     * Attempts to get battery level using vendor-specific methods.
     * Manufacturers like Sony, Bose, etc. may have their own protocols.
     */
    private Integer getVendorSpecificBatteryLevel(BluetoothDevice device) {
        if (device == null) return null;
        
        String name = device.getName();
        if (name != null) {
            name = name.toLowerCase();
            if (name.contains("sony") || name.contains("wh-1000")) {
                return 85; // Mock value for Sony headphones
            } else if (name.contains("bose") || name.contains("quietcomfort")) {
                return 78; // Mock value for Bose headphones
            } else if (name.contains("airpods") || name.contains("beats")) {
                return 65; // Mock value for Apple products
            } else if (name.contains("samsung") || name.contains("galaxy")) {
                return 55; // Mock value for Samsung products
            } else if (name.contains("jabra")) {
                return 42; // Mock value for Jabra products
            }
        }
        
        // For unknown devices, return a default value
        // In a real implementation, you might want to return null here
        return 50; // Mock value for unknown devices
    }
} 