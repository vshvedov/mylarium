package com.vsh.mylarium

import android.graphics.Rect
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "mylarium/system_gestures"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Draw edge to edge on every Android version (15+ already enforces it).
        // The Flutter view then always fills the window, so toggling the reader's
        // immersive mode changes only the inset padding, never the view size.
        // Without this, on Android 13/14 the default activity insets for the
        // system bars: leaving the reader brings the nav bar back, shrinks the
        // view, and the revealed home/series list reflows (a visible "jump").
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setGestureExclusion" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        setGestureExclusion(enabled)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // On Android 10+ (gesture navigation), exclude the whole window from the
    // system back / app-switch edge gesture so the reader's horizontal page
    // swipes near an edge are not stolen. Cleared when the reader closes. (The OS
    // caps how much it honors near each edge, but this resolves most accidental
    // back/switch swipes while reading.)
    private fun setGestureExclusion(enabled: Boolean) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return
        val root = window?.decorView ?: return
        root.post {
            root.systemGestureExclusionRects =
                if (enabled) listOf(Rect(0, 0, root.width, root.height))
                else emptyList()
        }
    }
}
