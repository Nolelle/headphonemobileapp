package com.example.projects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.Intent;
import android.provider.Settings;
import android.os.Build;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothProfile;
// Remove both problematic imports
// import android.bluetooth.BluetoothLeAudioCodecConfigMetadata;
// import android.bluetooth.BluetoothLeAudio;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import android.os.Handler;
import android.os.Looper;
import android.os.ParcelUuid;
import android.content.pm.PackageManager;
import android.Manifest;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

// Import LE Audio classes conditionally for Android 12+
// This is a workaround for the build error
// These imports will only be used if the device is running Android 12+
// @SuppressWarnings("unused")
// private static class AndroidSVersionCheck {
//     // This class is only used to conditionally import classes
//     // It will never be instantiated
//     static {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//             try {
//                 Class.forName("android.bluetooth.BluetoothLeAudioCodecConfigMetadata");
//                 Class.forName("android.bluetooth.BluetoothLeAudio");
//             } catch (ClassNotFoundException e) {
//                 // Classes not available, will be handled at runtime
//             }
//         }
//     }
// }

public class MainActivity extends FlutterActivity {
    private static final String SETTINGS_CHANNEL = "com.headphonemobileapp/settings";
    private static final String BT_CHANNEL = "com.headphonemobileapp/bluetooth";
    private static final int REQUEST_BLUETOOTH_PERMISSIONS = 1;
    
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothLeScanner bluetoothLeScanner;
    private boolean isScanning = false;
    private Handler scanHandler = new Handler(Looper.getMainLooper());
    private Map<String, BluetoothDevice> scannedDevices = new HashMap<>();
    private BluetoothDevice connectedDevice = null;
    
    // Audio-specific profile constants
    private static final int A2DP_PROFILE = BluetoothProfile.A2DP;
    private static final int HEADSET_PROFILE = BluetoothProfile.HEADSET;
    // Define LE_AUDIO_PROFILE conditionally
    private static final int LE_AUDIO_PROFILE;
    
    static {
        // Initialize LE_AUDIO_PROFILE based on Android version
        // BluetoothProfile.LE_AUDIO is only available on Android 12+
        int leAudioProfile;
        try {
            // Try to access the LE_AUDIO constant if available
            if (Build.VERSION.SDK_INT >= 31) { // Android 12 is API 31
                leAudioProfile = 22; // This is the value of BluetoothProfile.LE_AUDIO on Android 12+
            } else {
                leAudioProfile = -1; // Not available
            }
        } catch (Throwable t) {
            leAudioProfile = -1; // Not available or error
        }
        LE_AUDIO_PROFILE = leAudioProfile;
    }
    
    // Track Bluetooth profile proxies
    private BluetoothProfile leAudioProxy = null;
    private BluetoothProfile a2dpProxy = null;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        // Initialize Bluetooth adapter
        BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        bluetoothAdapter = bluetoothManager.getAdapter();
        
        // Register for Bluetooth state changes
        IntentFilter filter = new IntentFilter();
        filter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED);
        filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
        registerReceiver(bluetoothStateReceiver, filter);
        
        // Settings channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), SETTINGS_CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("openBluetoothSettings")) {
                        openBluetoothSettings();
                        result.success(null);
                    } else if (call.method.equals("getDeviceModel")) {
                        result.success(getDeviceModel());
                    } else {
                        result.notImplemented();
                    }
                }
            );
        
        // Bluetooth channel with expanded LE Audio support
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), BT_CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "isBluetoothEnabled":
                            result.success(isBluetoothEnabled());
                            break;
                        case "startScan":
                            if (hasRequiredPermissions()) {
                                startBluetoothScan();
                                result.success(null);
                            } else {
                                requestBluetoothPermissions();
                                result.error("PERMISSION_DENIED", "Bluetooth scan permission not granted", null);
                            }
                            break;
                        case "stopScan":
                            stopBluetoothScan();
                            result.success(null);
                            break;
                        case "getScannedDevices":
                            result.success(getScannedDevicesAsMap());
                            break;
                        case "connectToDevice":
                            String deviceId = call.argument("deviceId");
                            connectToDevice(deviceId, result);
                            break;
                        case "disconnectDevice":
                            disconnectDevice(result);
                            break;
                        case "getConnectedDevice":
                            result.success(getConnectedDeviceAsMap());
                            break;
                        case "isAudioDeviceConnected":
                            result.success(isAnyAudioDeviceConnected());
                            break;
                        case "isClassicAudioConnected":
                            result.success(isClassicAudioConnected());
                            break;
                        case "isLEAudioConnected":
                            result.success(isLEAudioConnected());
                            break;
                        case "forceAudioRoutingToBluetooth":
                            forceAudioRoutingToBluetooth();
                            result.success(null);
                            break;
                        case "getBtConnectionType":
                            result.success(getBluetoothConnectionType());
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                }
            );
            
        // Initialize profile proxies for LE Audio and A2DP
        initAudioProxies();
    }
    
    private void initAudioProxies() {
        // Initialize LE Audio proxy if available (Android 12+)
        if (Build.VERSION.SDK_INT >= 31 && LE_AUDIO_PROFILE > 0) { // Android 12 is API 31
            try {
                bluetoothAdapter.getProfileProxy(this, new BluetoothProfile.ServiceListener() {
                    @Override
                    public void onServiceConnected(int profile, BluetoothProfile proxy) {
                        if (profile == LE_AUDIO_PROFILE) {
                            leAudioProxy = proxy;
                        }
                    }

                    @Override
                    public void onServiceDisconnected(int profile) {
                        if (profile == LE_AUDIO_PROFILE) {
                            leAudioProxy = null;
                        }
                    }
                }, LE_AUDIO_PROFILE);
            } catch (Exception e) {
                // LE Audio not supported on this device
                System.out.println("LE Audio not supported: " + e.getMessage());
            }
        }
        
        // Initialize A2DP proxy for classic Bluetooth audio
        bluetoothAdapter.getProfileProxy(this, new BluetoothProfile.ServiceListener() {
            @Override
            public void onServiceConnected(int profile, BluetoothProfile proxy) {
                if (profile == A2DP_PROFILE) {
                    a2dpProxy = proxy;
                }
            }

            @Override
            public void onServiceDisconnected(int profile) {
                if (profile == A2DP_PROFILE) {
                    a2dpProxy = null;
                }
            }
        }, A2DP_PROFILE);
    }
    
    // Check permissions
    private boolean hasRequiredPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED &&
                   ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED;
        } else {
            return ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED;
        }
    }
    
    // Request permissions
    private void requestBluetoothPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ActivityCompat.requestPermissions(
                this,
                new String[]{
                    Manifest.permission.BLUETOOTH_SCAN,
                    Manifest.permission.BLUETOOTH_CONNECT
                },
                REQUEST_BLUETOOTH_PERMISSIONS
            );
        } else {
            ActivityCompat.requestPermissions(
                this,
                new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                REQUEST_BLUETOOTH_PERMISSIONS
            );
        }
    }
    
    // Check if Bluetooth is enabled
    private boolean isBluetoothEnabled() {
        return bluetoothAdapter != null && bluetoothAdapter.isEnabled();
    }
    
    // Start Bluetooth LE scan
    private void startBluetoothScan() {
        if (!isBluetoothEnabled() || isScanning) return;
        
        scannedDevices.clear();
        bluetoothLeScanner = bluetoothAdapter.getBluetoothLeScanner();
        
        if (bluetoothLeScanner == null) return;
        
        isScanning = true;
        
        // Configure scan settings for LE Audio devices
        ScanSettings settings = new ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build();
            
        // Start scanning
        bluetoothLeScanner.startScan(null, settings, scanCallback);
        
        // Stop scan after 10 seconds
        scanHandler.postDelayed(() -> {
            stopBluetoothScan();
        }, 10000);
    }
    
    // Stop Bluetooth scan
    private void stopBluetoothScan() {
        if (isScanning && bluetoothLeScanner != null) {
            isScanning = false;
            bluetoothLeScanner.stopScan(scanCallback);
        }
    }
    
    // Scan callback
    private final ScanCallback scanCallback = new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            BluetoothDevice device = result.getDevice();
            if (device.getName() != null && !device.getName().isEmpty()) {
                scannedDevices.put(device.getAddress(), device);
            }
        }

        @Override
        public void onBatchScanResults(List<ScanResult> results) {
            for (ScanResult result : results) {
                BluetoothDevice device = result.getDevice();
                if (device.getName() != null && !device.getName().isEmpty()) {
                    scannedDevices.put(device.getAddress(), device);
                }
            }
        }

        @Override
        public void onScanFailed(int errorCode) {
            isScanning = false;
        }
    };
    
    // Get scanned devices as a map for Flutter
    private List<Map<String, Object>> getScannedDevicesAsMap() {
        List<Map<String, Object>> devicesList = new ArrayList<>();
        
        for (BluetoothDevice device : scannedDevices.values()) {
            Map<String, Object> deviceMap = new HashMap<>();
            deviceMap.put("id", device.getAddress());
            deviceMap.put("name", device.getName() != null ? device.getName() : "Unknown Device");
            deviceMap.put("type", getDeviceTypeString(device.getType()));
            
            devicesList.add(deviceMap);
        }
        
        return devicesList;
    }
    
    // Get device type as string
    private String getDeviceTypeString(int type) {
        switch (type) {
            case BluetoothDevice.DEVICE_TYPE_CLASSIC:
                return "classic";
            case BluetoothDevice.DEVICE_TYPE_LE:
                return "le";
            case BluetoothDevice.DEVICE_TYPE_DUAL:
                return "dual";
            default:
                return "unknown";
        }
    }
    
    // Connect to device
    private void connectToDevice(String deviceId, MethodChannel.Result result) {
        if (deviceId == null) {
            result.error("INVALID_ARGUMENT", "Device ID cannot be null", null);
            return;
        }
        
        BluetoothDevice device = scannedDevices.get(deviceId);
        if (device == null) {
            // Try to get the device by address directly
            try {
                device = bluetoothAdapter.getRemoteDevice(deviceId);
            } catch (IllegalArgumentException e) {
                result.error("INVALID_DEVICE", "Device not found", null);
                return;
            }
        }
        
        if (device != null) {
            try {
                // For Android 12+ and LE Audio devices, use createBond for LE Audio
                boolean bondStarted = device.createBond();
                
                if (bondStarted) {
                    connectedDevice = device;
                    result.success(true);
                } else {
                    result.error("CONNECTION_FAILED", "Could not initiate bonding", null);
                }
            } catch (Exception e) {
                result.error("CONNECTION_ERROR", e.getMessage(), null);
            }
        } else {
            result.error("DEVICE_NOT_FOUND", "Device not found", null);
        }
    }
    
    // Disconnect current device
    private void disconnectDevice(MethodChannel.Result result) {
        if (connectedDevice != null) {
            try {
                // For LE Audio, we can remove the bond
                // For thorough disconnection, you might need to utilize profile proxies
                
                // Use BluetoothDevice.ACTION_ACL_DISCONNECTED to detect when fully disconnected
                // This is handled in the BroadcastReceiver
                
                connectedDevice = null;
                result.success(true);
            } catch (Exception e) {
                result.error("DISCONNECT_ERROR", e.getMessage(), null);
            }
        } else {
            result.success(true); // Already disconnected
        }
    }
    
    // Get connected device as map
    private Map<String, Object> getConnectedDeviceAsMap() {
    // First check if we have already detected a connection
    if (connectedDevice != null) {
        // Return connected device details
    }
    
    // Otherwise, check for connected audio devices through profiles
    
    // Check A2DP (Classic Bluetooth) connections
    if (a2dpProxy != null) {
        List<BluetoothDevice> a2dpDevices = a2dpProxy.getConnectedDevices();
        if (!a2dpDevices.isEmpty()) {
            connectedDevice = a2dpDevices.get(0);
            // Return device details
        }
    }
    
    // Check LE Audio connections
    if (Build.VERSION.SDK_INT >= 31 && leAudioProxy != null) {
        List<BluetoothDevice> leAudioDevices = leAudioProxy.getConnectedDevices();
        if (!leAudioDevices.isEmpty()) {
            connectedDevice = leAudioDevices.get(0);
            // Return device details
        }
    }
    
    // Also check system audio routing
    AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
    if (audioManager.isBluetoothA2dpOn() || audioManager.isBluetoothScoOn()) {
        // System reports Bluetooth audio is active, but we couldn't find the device
        // Try to get from bonded devices
        Set<BluetoothDevice> bondedDevices = bluetoothAdapter.getBondedDevices();
        for (BluetoothDevice device : bondedDevices) {
            // Check if this device is connected via audio profiles
            // This is a fallback approach
        }
    }
    
    return null; // No device found
}
    
    // Open Bluetooth settings
    // In MainActivity.java
    private void openBluetoothSettings() {
    Intent intent = new Intent();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        intent.setAction(Settings.ACTION_BLUETOOTH_SETTINGS);
    } else {
        intent.setAction(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS);
    }
    
    // Add these flags to keep your app in the back stack
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
    
    startActivity(intent);
}
    
    // Broadcast receiver for Bluetooth state changes
    private final BroadcastReceiver bluetoothStateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();
            
            if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(action)) {
                // Handle Bluetooth state changes
            } else if (BluetoothDevice.ACTION_ACL_CONNECTED.equals(action)) {
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                connectedDevice = device;
            } else if (BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(action)) {
                connectedDevice = null;
            }
        }
    };
    
    // Check if any Bluetooth audio device is connected
    private boolean isAnyAudioDeviceConnected() {
        return isLEAudioConnected() || isClassicAudioConnected();
    }
    
    // Check for LE Audio connection
    private boolean isLEAudioConnected() {
        if (Build.VERSION.SDK_INT >= 31) { // Android 12 is API 31
            try {
                // Check for BLE audio devices
                AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
                AudioDeviceInfo[] devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);
                
                for (AudioDeviceInfo device : devices) {
                    // Constants for BLE audio device types (Android 12+)
                    // AudioDeviceInfo.TYPE_BLE_HEADSET = 26
                    // AudioDeviceInfo.TYPE_BLE_SPEAKER = 27
                    if (device.getType() == 26 || device.getType() == 27) {
                        return true;
                    }
                }
                
                // Additionally check via profile proxy if available
                if (leAudioProxy != null && LE_AUDIO_PROFILE > 0) {
                    List<BluetoothDevice> leAudioDevices = leAudioProxy.getConnectedDevices();
                    return !leAudioDevices.isEmpty();
                }
            } catch (Exception e) {
                // LE Audio API not available or error
                System.out.println("Error checking LE Audio: " + e.getMessage());
            }
        }
        return false;
    }
    
    // Check for classic Bluetooth audio connection
    private boolean isClassicAudioConnected() {
        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        boolean a2dpConnected = audioManager.isBluetoothA2dpOn();
        
        // Additionally check via profile proxy if available
        if (!a2dpConnected && a2dpProxy != null) {
            List<BluetoothDevice> a2dpDevices = a2dpProxy.getConnectedDevices();
            a2dpConnected = !a2dpDevices.isEmpty();
        }
        
        return a2dpConnected;
    }
    
    // Return a string indicating the type of Bluetooth connection
    private String getBluetoothConnectionType() {
        if (isLEAudioConnected()) {
            return "le_audio";
        } else if (isClassicAudioConnected()) {
            return "classic";
        } else {
            return "none";
        }
    }
    
    // Force audio routing with support for both classic and LE Audio
    private void forceAudioRoutingToBluetooth() {
        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        
        if (Build.VERSION.SDK_INT >= 31 && isLEAudioConnected()) { // Android 12 is API 31
            try {
                // For LE Audio on Android 12+, the system should handle routing automatically
                // We can't force routing directly, but we can ensure the audio focus
                audioManager.requestAudioFocus(null, AudioManager.STREAM_MUSIC, 
                                              AudioManager.AUDIOFOCUS_GAIN);
            } catch (Exception e) {
                // LE Audio API not available or error
                System.out.println("Error routing to LE Audio: " + e.getMessage());
            }
        } else {
            // Traditional SCO approach for classic Bluetooth
            audioManager.startBluetoothSco();
            audioManager.setBluetoothScoOn(true);
            
            // Give it a moment to connect
            new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                @Override
                public void run() {
                    if (!audioManager.isBluetoothScoOn()) {
                        audioManager.startBluetoothSco();
                    }
                }
            }, 1000);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        // Unregister the broadcast receiver
        unregisterReceiver(bluetoothStateReceiver);
        
        // Clean up profile proxies
        if (leAudioProxy != null && bluetoothAdapter != null) {
            bluetoothAdapter.closeProfileProxy(LE_AUDIO_PROFILE, leAudioProxy);
        }
        if (a2dpProxy != null && bluetoothAdapter != null) {
            bluetoothAdapter.closeProfileProxy(A2DP_PROFILE, a2dpProxy);
        }
    }

    private String getDeviceModel() {
        return Build.MODEL;
    }
}
