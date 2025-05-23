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
import android.bluetooth.BluetoothHeadset;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
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
import android.util.Log;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import org.json.JSONObject;
import org.json.JSONException;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.lang.reflect.Method;
import java.util.Random;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.io.File;
import java.io.FileOutputStream;
import android.net.Uri;
import androidx.core.content.FileProvider;

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
    private static final String BLE_DATA_CHANNEL = "com.headphonemobileapp/ble_data";
    private static final String BT_FILE_CHANNEL = "com.headphonemobileapp/bt_file";
    private static final int REQUEST_BLUETOOTH_PERMISSIONS = 1;
    
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothLeScanner bluetoothLeScanner;
    private boolean isScanning = false;
    private Handler scanHandler = new Handler(Looper.getMainLooper());
    private Map<String, BluetoothDevice> scannedDevices = new HashMap<>();
    private BluetoothDevice connectedDevice = null;
    private BluetoothHeadset bluetoothHeadset; // BluetoothHeadset proxy
    
    // BLE Data transmission stuff
    private Executor bgExecutor = Executors.newSingleThreadExecutor();
    private Handler mainHandler = new Handler(Looper.getMainLooper());
    private Random random = new Random();
    
    // UUID for BLE characteristics we'll use for JSON transfer (standard UUIDs)
    private static final UUID HEARING_TEST_CHAR_UUID = UUID.fromString("00002A1C-0000-1000-8000-00805f9b34fb");
    private static final UUID PRESET_CHAR_UUID = UUID.fromString("00002A1D-0000-1000-8000-00805f9b34fb");
    private static final UUID COMBINED_DATA_CHAR_UUID = UUID.fromString("00002A1E-0000-1000-8000-00805f9b34fb");
    
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
                        case "getBatteryLevel":
                            getBatteryLevel(result);
                            break;
                        case "openBluetoothSettings":
                            openBluetoothSettings();
                            result.success(null);
                            break;
                        case "retryGetDeviceName":
                            retryGetDeviceName(result);
                            break;
                        case "retryGetBatteryLevel":
                            retryGetBatteryLevel(result);
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                }
            );
            
        // Add BLE Data channel for JSON transmission
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), BLE_DATA_CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "writeCharacteristic":
                            String characteristicUuid = call.argument("characteristicUuid");
                            byte[] data = call.argument("data");
                            Boolean withoutResponse = call.argument("withoutResponse");
                            
                            if (characteristicUuid != null && data != null) {
                                handleWriteCharacteristic(characteristicUuid, data, withoutResponse != null ? withoutResponse : false, result);
                            } else {
                                result.error("INVALID_ARGUMENTS", "Missing characteristicUuid or data", null);
                            }
                            break;
                        case "isGattReady":
                            // Simulate GATT service discovery
                            result.success(true);
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                }
            );
            
        // Add Bluetooth File Transfer channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), BT_FILE_CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "sendFile":
                            String jsonData = call.argument("jsonData");
                            String fileName = call.argument("fileName");
                            
                            if (jsonData != null && fileName != null) {
                                sendFileViaBluetooth(jsonData, fileName, result);
                            } else {
                                result.error("INVALID_ARGUMENTS", "Missing jsonData or fileName", null);
                            }
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
    
    private void handleWriteCharacteristic(
        String characteristicUuid, 
        byte[] data, 
        boolean withoutResponse,
        MethodChannel.Result result
    ) {
        // Perform the write operation in a background thread to simulate network operation
        bgExecutor.execute(() -> {
            try {
                // Log the data being sent for debugging
                String jsonString = new String(data, "UTF-8");
                Log.d("MainActivity", "Writing to characteristic: " + characteristicUuid);
                Log.d("MainActivity", "Data length: " + data.length + " bytes");
                
                // Create a JSON object from the data for logging purposes
                try {
                    JSONObject jsonObject = new JSONObject(jsonString);
                    final String dataType; // Make it explicitly final
                    
                    if (characteristicUuid.contains("2A1C")) {
                        dataType = "Hearing Test";
                    } else if (characteristicUuid.contains("2A1D")) {
                        dataType = "Preset";
                    } else if (characteristicUuid.contains("2A1E")) {
                        dataType = "Combined";
                    } else {
                        dataType = "Unknown";
                    }
                    
                    // Log data type and size
                    Log.i("MainActivity", "Sent " + dataType + " data (" + data.length + " bytes)");
                    
                    // Simulate network delay
                    long delay = 50 + random.nextInt(150);
                    Thread.sleep(delay);
                    
                    // Show toast on UI thread for demonstration
                    mainHandler.post(() -> {
                        Toast.makeText(
                            getApplicationContext(),
                            "Sent " + dataType + " data (" + data.length + " bytes)",
                            Toast.LENGTH_SHORT
                        ).show();
                    });
                } catch (JSONException e) {
                    Log.e("MainActivity", "Invalid JSON: " + e.getMessage());
                }
                
                // Return success on main thread
                mainHandler.post(() -> {
                    result.success(true);
                });
            } catch (Exception e) {
                Log.e("MainActivity", "Error writing characteristic: " + e.getMessage());
                mainHandler.post(() -> {
                    result.error("WRITE_ERROR", "Failed to write: " + e.getMessage(), null);
                });
            }
        });
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
                            Log.d("MainActivity", "LE Audio proxy connected");
                        }
                    }
                    
                    @Override
                    public void onServiceDisconnected(int profile) {
                        if (profile == LE_AUDIO_PROFILE) {
                            leAudioProxy = null;
                            Log.d("MainActivity", "LE Audio proxy disconnected");
                        }
                    }
                }, LE_AUDIO_PROFILE);
            } catch (Exception e) {
                Log.e("MainActivity", "Error initializing LE Audio proxy: " + e.getMessage());
            }
        }
        
        // Initialize A2DP proxy
        try {
            bluetoothAdapter.getProfileProxy(this, new BluetoothProfile.ServiceListener() {
                @Override
                public void onServiceConnected(int profile, BluetoothProfile proxy) {
                    if (profile == A2DP_PROFILE) {
                        a2dpProxy = proxy;
                        Log.d("MainActivity", "A2DP proxy connected");
                    }
                }
                
                @Override
                public void onServiceDisconnected(int profile) {
                    if (profile == A2DP_PROFILE) {
                        a2dpProxy = null;
                        Log.d("MainActivity", "A2DP proxy disconnected");
                    }
                }
            }, A2DP_PROFILE);
        } catch (Exception e) {
            Log.e("MainActivity", "Error initializing A2DP proxy: " + e.getMessage());
        }
        
        // Initialize BluetoothHeadset proxy for HFP
        try {
            bluetoothAdapter.getProfileProxy(this, new BluetoothProfile.ServiceListener() {
                @Override
                public void onServiceConnected(int profile, BluetoothProfile proxy) {
                    if (profile == BluetoothProfile.HEADSET) {
                        bluetoothHeadset = (BluetoothHeadset) proxy;
                        Log.d("MainActivity", "BluetoothHeadset proxy connected");
                    }
                }
                
                @Override
                public void onServiceDisconnected(int profile) {
                    if (profile == BluetoothProfile.HEADSET) {
                        bluetoothHeadset = null;
                        Log.d("MainActivity", "BluetoothHeadset proxy disconnected");
                    }
                }
            }, BluetoothProfile.HEADSET);
        } catch (Exception e) {
            Log.e("MainActivity", "Error initializing BluetoothHeadset proxy: " + e.getMessage());
        }
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
        Log.d("MainActivity", "Getting connected device info");
        
        // First check if we have already detected a connection
        if (connectedDevice != null) {
            Log.d("MainActivity", "Using cached connected device: " + connectedDevice.getName());
            Map<String, Object> deviceMap = new HashMap<>();
            deviceMap.put("id", connectedDevice.getAddress());
            deviceMap.put("name", connectedDevice.getName() != null ? connectedDevice.getName() : "Unknown Device");
            deviceMap.put("type", getDeviceType(connectedDevice));
            // Don't add mock battery level
            deviceMap.put("batteryLevel", null);
            return deviceMap;
        }
        
        Log.d("MainActivity", "No cached device, checking profiles");
        
        // Otherwise, check for connected audio devices through profiles
        
        // Check A2DP (Classic Bluetooth) connections
        if (a2dpProxy != null) {
            List<BluetoothDevice> a2dpDevices = a2dpProxy.getConnectedDevices();
            Log.d("MainActivity", "A2DP devices found: " + a2dpDevices.size());
            if (!a2dpDevices.isEmpty()) {
                connectedDevice = a2dpDevices.get(0);
                Log.d("MainActivity", "Found A2DP device: " + connectedDevice.getName());
                Map<String, Object> deviceMap = new HashMap<>();
                deviceMap.put("id", connectedDevice.getAddress());
                deviceMap.put("name", connectedDevice.getName() != null ? connectedDevice.getName() : "Unknown Device");
                deviceMap.put("type", "classic");
                deviceMap.put("audioType", "classic");
                // Don't add mock battery level
                deviceMap.put("batteryLevel", null);
                return deviceMap;
            }
        } else {
            Log.d("MainActivity", "A2DP proxy is null");
        }
        
        // Check LE Audio connections
        if (Build.VERSION.SDK_INT >= 31 && leAudioProxy != null) {
            List<BluetoothDevice> leAudioDevices = leAudioProxy.getConnectedDevices();
            Log.d("MainActivity", "LE Audio devices found: " + leAudioDevices.size());
            if (!leAudioDevices.isEmpty()) {
                connectedDevice = leAudioDevices.get(0);
                Log.d("MainActivity", "Found LE Audio device: " + connectedDevice.getName());
                Map<String, Object> deviceMap = new HashMap<>();
                deviceMap.put("id", connectedDevice.getAddress());
                deviceMap.put("name", connectedDevice.getName() != null ? connectedDevice.getName() : "Unknown Device");
                deviceMap.put("type", "le");
                deviceMap.put("audioType", "le_audio");
                // Don't add mock battery level
                deviceMap.put("batteryLevel", null);
                return deviceMap;
            }
        } else {
            Log.d("MainActivity", "LE Audio proxy is null or not supported on this Android version");
        }
        
        // Also check system audio routing
        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        boolean isBluetoothAudioActive = audioManager.isBluetoothA2dpOn() || audioManager.isBluetoothScoOn();
        Log.d("MainActivity", "Bluetooth audio active according to AudioManager: " + isBluetoothAudioActive);
        
        if (isBluetoothAudioActive) {
            // System reports Bluetooth audio is active, but we couldn't find the device through profiles
            // Try to get from bonded devices
            Set<BluetoothDevice> bondedDevices = bluetoothAdapter.getBondedDevices();
            Log.d("MainActivity", "Number of bonded devices: " + bondedDevices.size());
            
            for (BluetoothDevice device : bondedDevices) {
                // Log all bonded devices to help with debugging
                Log.d("MainActivity", "Bonded device: " + device.getName() + " [" + device.getAddress() + "]");
            }
            
            // As a fallback, use the first bonded device if audio is active
            if (!bondedDevices.isEmpty()) {
                connectedDevice = bondedDevices.iterator().next();
                Log.d("MainActivity", "Using first bonded device as fallback: " + connectedDevice.getName());
                Map<String, Object> deviceMap = new HashMap<>();
                deviceMap.put("id", connectedDevice.getAddress());
                deviceMap.put("name", connectedDevice.getName() != null ? connectedDevice.getName() : "Unknown Device");
                deviceMap.put("type", getDeviceType(connectedDevice));
                deviceMap.put("audioType", "classic"); // Assume classic as fallback
                // Don't add mock battery level
                deviceMap.put("batteryLevel", null);
                return deviceMap;
            }
        }
        
        Log.d("MainActivity", "No connected Bluetooth audio device found");
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
    
    // Add method to retry getting device name
    private void retryGetDeviceName(MethodChannel.Result result) {
        Log.d("MainActivity", "Retrying to get device name");
        
        if (connectedDevice != null) {
            // Force refresh the name
            String deviceName = connectedDevice.getName();
            Log.d("MainActivity", "Retry getting name for device: " + deviceName);
            
            if (deviceName != null && !deviceName.equals("Unknown Device")) {
                // We got a proper name now
                Map<String, Object> deviceMap = new HashMap<>();
                deviceMap.put("id", connectedDevice.getAddress());
                deviceMap.put("name", deviceName);
                deviceMap.put("type", getDeviceType(connectedDevice));
                deviceMap.put("audioType", getBluetoothConnectionType());
                deviceMap.put("batteryLevel", null);
                
                result.success(deviceMap);
                return;
            } else {
                // Try to get from bonded devices by address
                String address = connectedDevice.getAddress();
                Set<BluetoothDevice> bondedDevices = bluetoothAdapter.getBondedDevices();
                
                for (BluetoothDevice device : bondedDevices) {
                    if (device.getAddress().equals(address)) {
                        String bondedName = device.getName();
                        Log.d("MainActivity", "Found bonded device with matching address, name: " + bondedName);
                        
                        if (bondedName != null && !bondedName.isEmpty()) {
                            Map<String, Object> deviceMap = new HashMap<>();
                            deviceMap.put("id", address);
                            deviceMap.put("name", bondedName);
                            deviceMap.put("type", getDeviceType(device));
                            deviceMap.put("audioType", getBluetoothConnectionType());
                            deviceMap.put("batteryLevel", null);
                            
                            result.success(deviceMap);
                            return;
                        }
                    }
                }
                
                // Still no luck, try to get any connected device as a fallback
                Map<String, Object> deviceMap = getConnectedDeviceAsMap();
                result.success(deviceMap);
                return;
            }
        } else {
            // No device connected, try to find any connected device
            Map<String, Object> deviceMap = getConnectedDeviceAsMap();
            result.success(deviceMap);
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
        if (bluetoothHeadset != null && bluetoothAdapter != null) {
            bluetoothAdapter.closeProfileProxy(BluetoothProfile.HEADSET, bluetoothHeadset);
        }
        
        // Clean up GATT connection
        if (mGatt != null) {
            mGatt.disconnect();
            mGatt.close();
            mGatt = null;
        }
    }

    private String getDeviceModel() {
        return Build.MODEL;
    }

    // GATT Battery Service Constants
    private BluetoothGatt mGatt;
    private boolean isGattConnecting = false;
    private static final UUID BATTERY_SERVICE_UUID = UUID.fromString("0000180F-0000-1000-8000-00805F9B34FB");
    private static final UUID BATTERY_LEVEL_CHAR_UUID = UUID.fromString("00002A19-0000-1000-8000-00805F9B34FB");
    
    // Battery level caching
    private Integer cachedBatteryLevel = null;
    private long lastBatteryCheckTime = 0;
    private static final long BATTERY_CACHE_DURATION = 60000; // 1 minute
    
    // GATT callback for battery service
    private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                Log.d("MainActivity", "Connected to GATT server.");
                gatt.discoverServices();
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                Log.d("MainActivity", "Disconnected from GATT server.");
                isGattConnecting = false;
                mGatt = null;
            }
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                BluetoothGattService batteryService = gatt.getService(BATTERY_SERVICE_UUID);
                if (batteryService == null) {
                    Log.d("MainActivity", "Battery service not found");
                    gatt.disconnect();
                    isGattConnecting = false;
                    return;
                }

                BluetoothGattCharacteristic batteryChar = 
                    batteryService.getCharacteristic(BATTERY_LEVEL_CHAR_UUID);
                if (batteryChar == null) {
                    Log.d("MainActivity", "Battery characteristic not found");
                    gatt.disconnect();
                    isGattConnecting = false;
                    return;
                }

                boolean success = gatt.readCharacteristic(batteryChar);
                Log.d("MainActivity", "Reading battery characteristic: " + success);
                if (!success) {
                    gatt.disconnect();
                    isGattConnecting = false;
                }
            } else {
                Log.d("MainActivity", "Service discovery failed: " + status);
                gatt.disconnect();
                isGattConnecting = false;
            }
        }

        @Override
        public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, 
                                        int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                if (BATTERY_LEVEL_CHAR_UUID.equals(characteristic.getUuid())) {
                    int batteryLevel = characteristic.getIntValue(
                        BluetoothGattCharacteristic.FORMAT_UINT8, 0);
                    Log.d("MainActivity", "Battery level from GATT: " + batteryLevel);
                    
                    // Update cached battery level
                    cachedBatteryLevel = batteryLevel;
                    lastBatteryCheckTime = System.currentTimeMillis();
                    
                    gatt.disconnect();
                    isGattConnecting = false;
                }
            } else {
                Log.d("MainActivity", "Failed to read characteristic: " + status);
                gatt.disconnect();
                isGattConnecting = false;
            }
        }
    };

    // Return battery level of connected Bluetooth headphones
    private void getBatteryLevel(final MethodChannel.Result result) {
        if (!isAnyAudioDeviceConnected() || connectedDevice == null) {
            result.success(null); // No device connected
            return;
        }
        
        // Check if we have a recent cached value (within last minute)
        if (cachedBatteryLevel != null && 
            System.currentTimeMillis() - lastBatteryCheckTime < BATTERY_CACHE_DURATION) {
            Log.d("MainActivity", "Using cached battery level: " + cachedBatteryLevel);
            result.success(cachedBatteryLevel);
            return;
        }
        
        // Try HFP approach first (faster)
        Integer hfpBattery = getBatteryLevelFromHfp();
        if (hfpBattery != null) {
            Log.d("MainActivity", "Got battery level from HFP: " + hfpBattery);
            cachedBatteryLevel = hfpBattery;
            lastBatteryCheckTime = System.currentTimeMillis();
            result.success(hfpBattery);
            return;
        }
        
        // Then try GATT approach (works for more devices but slower)
        if (!isGattConnecting && mGatt == null) {
            Log.d("MainActivity", "Trying to get battery level via GATT...");
            
            // Set up a timeout for GATT connection
            new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                @Override
                public void run() {
                    if (isGattConnecting) {
                        Log.d("MainActivity", "GATT battery level request timed out");
                        isGattConnecting = false;
                        if (mGatt != null) {
                            mGatt.disconnect();
                            mGatt.close();
                            mGatt = null;
                        }
                        
                        // Return null instead of using mock data
                        Log.d("MainActivity", "Battery level not available");
                        cachedBatteryLevel = null;
                        lastBatteryCheckTime = System.currentTimeMillis();
                        result.success(null);
                    }
                }
            }, 5000); // 5 second timeout
            
            // Connect to GATT
            try {
                isGattConnecting = true;
                mGatt = connectedDevice.connectGatt(this, false, gattCallback);
            } catch (Exception e) {
                Log.e("MainActivity", "Error connecting to GATT: " + e.getMessage());
                isGattConnecting = false;
                
                // Return null instead of using mock data
                Log.d("MainActivity", "Battery level not available");
                cachedBatteryLevel = null;
                lastBatteryCheckTime = System.currentTimeMillis();
                result.success(null);
            }
        } else {
            // If already connecting or GATT in use, return null instead of mock data
            Log.d("MainActivity", "GATT already in use, battery level not available");
            result.success(null);
        }
    }
    
    // Get battery level from HFP (Hands-Free Profile)
    private Integer getBatteryLevelFromHfp() {
        if (Build.VERSION.SDK_INT < 29) { // Android 10 is API 29
            return null; // Not supported on older Android versions
        }
        
        try {
            // Need to use reflection as this API is not public
            Method getBatteryLevelMethod = 
                BluetoothHeadset.class.getMethod("getBatteryLevel", BluetoothDevice.class);
            
            if (bluetoothHeadset != null && connectedDevice != null) {
                Object result = getBatteryLevelMethod.invoke(bluetoothHeadset, connectedDevice);
                if (result instanceof Integer) {
                    int level = (Integer) result;
                    return level >= 0 ? level : null; // -1 means not available
                }
            }
        } catch (Exception e) {
            Log.e("MainActivity", "Error getting HFP battery level: " + e.getMessage());
        }
        
        return null;
    }

    // Helper method to get device type as a string
    private String getDeviceType(BluetoothDevice device) {
        if (device == null) return "unknown";
        
        try {
            int deviceType = device.getType();
            switch (deviceType) {
                case BluetoothDevice.DEVICE_TYPE_CLASSIC:
                    return "classic";
                case BluetoothDevice.DEVICE_TYPE_LE:
                    return "le";
                case BluetoothDevice.DEVICE_TYPE_DUAL:
                    return "dual";
                default:
                    return "unknown";
            }
        } catch (Exception e) {
            // On older Android versions, getType might throw an exception
            Log.d("MainActivity", "Error getting device type: " + e.getMessage());
            return "unknown";
        }
    }

    // Method to send a file via classic Bluetooth
    private void sendFileViaBluetooth(String jsonData, String fileName, MethodChannel.Result result) {
        try {
            // Check if Bluetooth is enabled
            if (!isBluetoothEnabled()) {
                result.error("BLUETOOTH_DISABLED", "Bluetooth is not enabled", null);
                return;
            }
            
            // Check if we have the required permissions
            if (!hasRequiredPermissions()) {
                requestBluetoothPermissions();
                result.error("PERMISSION_DENIED", "Bluetooth permissions not granted", null);
                return;
            }
            
            // Create temporary file with the provided JSON data
            File tempDir = getApplicationContext().getCacheDir();
            File file = new File(tempDir, fileName);
            
            // Write JSON data to the file
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(jsonData.getBytes());
            fos.close();
            
            // Get content URI via FileProvider
            Uri contentUri = FileProvider.getUriForFile(
                getApplicationContext(),
                getApplicationContext().getPackageName() + ".fileprovider",
                file
            );
            
            // Create share intent
            Intent shareIntent = new Intent(Intent.ACTION_SEND);
            shareIntent.setType("application/json");
            shareIntent.putExtra(Intent.EXTRA_STREAM, contentUri);
            
            // Grant temporary read permission to the content URI
            shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            
            // Use Bluetooth if available
            shareIntent.putExtra(Intent.EXTRA_TITLE, "Share via Bluetooth");
            
            // Create chooser
            Intent chooser = Intent.createChooser(shareIntent, "Share via Bluetooth");
            
            // Start the chooser activity
            startActivity(chooser);
            
            // Return success to Flutter
            result.success(true);
            
            // Show toast
            Toast.makeText(
                getApplicationContext(),
                "Please select Bluetooth to share the file",
                Toast.LENGTH_LONG
            ).show();
            
        } catch (Exception e) {
            Log.e("BluetoothFileTransfer", "Error sending file: " + e.getMessage());
            result.error("SEND_ERROR", "Failed to send file: " + e.getMessage(), null);
        }
    }

    // Method to retry getting battery level with different approaches
    private void retryGetBatteryLevel(final MethodChannel.Result result) {
        Log.d("MainActivity", "Retrying to get battery level");
        
        if (!isAnyAudioDeviceConnected() || connectedDevice == null) {
            result.success(null); // No device connected
            return;
        }
        
        // First, invalidate any existing cached battery level
        cachedBatteryLevel = null;
        
        // Try HFP approach again (faster and more reliable)
        Integer hfpBattery = getBatteryLevelFromHfp();
        if (hfpBattery != null) {
            Log.d("MainActivity", "Retry successful - Got battery level from HFP: " + hfpBattery);
            cachedBatteryLevel = hfpBattery;
            lastBatteryCheckTime = System.currentTimeMillis();
            result.success(hfpBattery);
            return;
        }
        
        // If HFP fails and GATT is not already in use, try GATT approach
        if (!isGattConnecting && mGatt == null) {
            Log.d("MainActivity", "Retry - Trying to get battery level via GATT...");
            
            // Set up a timeout for GATT connection
            new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                @Override
                public void run() {
                    if (isGattConnecting) {
                        Log.d("MainActivity", "Retry - GATT battery level request timed out");
                        isGattConnecting = false;
                        if (mGatt != null) {
                            mGatt.disconnect();
                            mGatt.close();
                            mGatt = null;
                        }
                        
                        // Return null for the retry attempt
                        result.success(null);
                    }
                }
            }, 5000); // 5 second timeout
            
            // Connect to GATT
            try {
                isGattConnecting = true;
                mGatt = connectedDevice.connectGatt(this, false, new BluetoothGattCallback() {
                    @Override
                    public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
                        if (newState == BluetoothProfile.STATE_CONNECTED) {
                            Log.d("MainActivity", "Retry - Connected to GATT server");
                            gatt.discoverServices();
                        } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                            Log.d("MainActivity", "Retry - Disconnected from GATT server");
                            isGattConnecting = false;
                            mGatt = null;
                        }
                    }

                    @Override
                    public void onServicesDiscovered(BluetoothGatt gatt, int status) {
                        if (status == BluetoothGatt.GATT_SUCCESS) {
                            BluetoothGattService batteryService = gatt.getService(BATTERY_SERVICE_UUID);
                            if (batteryService == null) {
                                Log.d("MainActivity", "Retry - Battery service not found");
                                gatt.disconnect();
                                isGattConnecting = false;
                                mainHandler.post(() -> result.success(null));
                                return;
                            }

                            BluetoothGattCharacteristic batteryChar = 
                                batteryService.getCharacteristic(BATTERY_LEVEL_CHAR_UUID);
                            if (batteryChar == null) {
                                Log.d("MainActivity", "Retry - Battery characteristic not found");
                                gatt.disconnect();
                                isGattConnecting = false;
                                mainHandler.post(() -> result.success(null));
                                return;
                            }

                            boolean success = gatt.readCharacteristic(batteryChar);
                            Log.d("MainActivity", "Retry - Reading battery characteristic: " + success);
                            if (!success) {
                                gatt.disconnect();
                                isGattConnecting = false;
                                mainHandler.post(() -> result.success(null));
                            }
                        } else {
                            Log.d("MainActivity", "Retry - Service discovery failed: " + status);
                            gatt.disconnect();
                            isGattConnecting = false;
                            mainHandler.post(() -> result.success(null));
                        }
                    }

                    @Override
                    public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, 
                                                  int status) {
                        if (status == BluetoothGatt.GATT_SUCCESS) {
                            if (BATTERY_LEVEL_CHAR_UUID.equals(characteristic.getUuid())) {
                                int batteryLevel = characteristic.getIntValue(
                                    BluetoothGattCharacteristic.FORMAT_UINT8, 0);
                                Log.d("MainActivity", "Retry - Battery level from GATT: " + batteryLevel);
                                
                                // Update cached battery level
                                cachedBatteryLevel = batteryLevel;
                                lastBatteryCheckTime = System.currentTimeMillis();
                                
                                gatt.disconnect();
                                isGattConnecting = false;
                                
                                mainHandler.post(() -> result.success(batteryLevel));
                            }
                        } else {
                            Log.d("MainActivity", "Retry - Failed to read characteristic: " + status);
                            gatt.disconnect();
                            isGattConnecting = false;
                            mainHandler.post(() -> result.success(null));
                        }
                    }
                });
            } catch (Exception e) {
                Log.e("MainActivity", "Retry - Error connecting to GATT: " + e.getMessage());
                isGattConnecting = false;
                result.success(null);
            }
        } else {
            // If GATT is already in use, just return null
            Log.d("MainActivity", "Retry - GATT already in use, returning null");
            result.success(null);
        }
    }
}
