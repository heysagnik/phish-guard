package com.phisguard.phisguard

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.webkit.WebView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "default_browser_channel"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "isDefaultBrowser") {
                    val isDefault = isDefaultBrowser()
                    result.success(isDefault)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun isDefaultBrowser(): Boolean {
        val defaultBrowserPackage = packageManager.resolveActivity(
            Intent(Intent.ACTION_VIEW, android.net.Uri.parse("http://")),
            0
        )?.activityInfo?.packageName
        return defaultBrowserPackage == packageName
    }
}