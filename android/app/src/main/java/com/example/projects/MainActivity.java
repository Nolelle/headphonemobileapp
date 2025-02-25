package com.example.projects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.Intent;
import android.provider.Settings;
import android.os.Build;
import android.bluetooth.BluetoothAdapter;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.headphonemobileapp/settings";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("openBluetoothSettings")) {
                        openBluetoothSettings();
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }

    private void openBluetoothSettings() {
        Intent intent = new Intent();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            intent.setAction(Settings.ACTION_BLUETOOTH_SETTINGS);
        } else {
            intent.setAction(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS);
        }
        startActivity(intent);
    }
}
