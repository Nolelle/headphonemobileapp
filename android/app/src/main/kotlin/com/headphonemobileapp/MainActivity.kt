// File: android/app/src/main/kotlin/com/headphonemobileapp/MainActivity.kt

package com.headphonemobileapp

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothProfile
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val BLUETOOTH_CHANNEL = "com.headphonemobileapp/bluetooth"
    private val SETTINGS_CHANNEL = "com.headphonemobileapp/settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Bluetooth channel for checking connections
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BLUETOOTH_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAudioDeviceConnected" -> {
                    result.success(isAudioDeviceConnected())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Settings channel for opening system settings
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openBluetoothSettings" -> {
                    try {
                        val intent = Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SETTINGS_ERROR", "Failed to open Bluetooth settings", e.toString())
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun isAudioDeviceConnected(): Boolean {
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter() ?: return false
        if (!bluetoothAdapter.isEnabled) return false
        
        // Check for A2DP (audio) profile connections
        val a2dpConnected = bluetoothAdapter.getProfileConnectionState(BluetoothProfile.A2DP) == 
            BluetoothProfile.STATE_CONNECTED
            
        // Check for headset profile connections
        val headsetConnected = bluetoothAdapter.getProfileConnectionState(BluetoothProfile.HEADSET) == 
            BluetoothProfile.STATE_CONNECTED
            
        return a2dpConnected || headsetConnected
    }
}