package com.example.auto_entrepreneur_manager

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class MainActivity : FlutterActivity() {
    private var shortcutChannel: MethodChannel? = null
    private var pendingShortcut: Map<String, String>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureShortcut(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        shortcutChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHORTCUT_CHANNEL)
        shortcutChannel?.setMethodCallHandler { call, result ->
            if (call.method == "takePendingShortcut") {
                val delivery = pendingShortcut
                pendingShortcut = null
                // Only clear our own consumed launch marker. Leave widget/deep-link intents alone.
                if (delivery != null && intent.action == NEW_INVOICE_ACTION) {
                    intent.removeExtra("shortcut_id")
                    intent.action = Intent.ACTION_MAIN
                }
                result.success(delivery)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureShortcut(intent)
    }

    private fun captureShortcut(launchIntent: Intent) {
        if (launchIntent.action != NEW_INVOICE_ACTION ||
            launchIntent.getStringExtra("shortcut_id") != "New Invoice") return
        pendingShortcut = mapOf(
            "deliveryId" to UUID.randomUUID().toString(),
            "shortcutId" to "New Invoice",
        )
        // If Dart is not ready yet, its startup drain will retrieve the queued delivery.
        shortcutChannel?.invokeMethod("shortcutAvailable", null)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        shortcutChannel?.setMethodCallHandler(null)
        shortcutChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    companion object {
        private const val SHORTCUT_CHANNEL = "auto_entrepreneur_manager/shortcuts"
        private const val NEW_INVOICE_ACTION = "com.example.auto_entrepreneur_manager.action.NEW_INVOICE"
    }
}
