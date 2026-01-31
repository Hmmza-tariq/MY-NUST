package com.hexagone.mynust

import android.os.Build
import android.os.Bundle
import android.webkit.WebView
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.reflect.Field
import java.lang.reflect.Method

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.hexagone.mynust/webview"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable WebView debugging globally
        WebView.setWebContentsDebuggingEnabled(true)
        
        // Try to configure WebView to accept all SSL certificates
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                // Clear any cached SSL decisions
                android.webkit.WebStorage.getInstance().deleteAllData()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "clearSslPreferences" -> {
                    try {
                        android.webkit.WebStorage.getInstance().deleteAllData()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
