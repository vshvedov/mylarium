package com.vsh.mylarium

import android.graphics.Rect
import android.opengl.EGL14
import android.opengl.EGLConfig
import android.opengl.EGLContext
import android.opengl.EGLDisplay
import android.opengl.EGLSurface
import android.opengl.GLES20
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "mylarium/system_gestures"
    private val deviceChannelName = "mylarium/device"

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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "maxTextureSize" -> result.success(probeMaxTextureSize())
                    else -> result.notImplemented()
                }
            }
    }

    // Query the GPU's GL_MAX_TEXTURE_SIZE via a throwaway offscreen EGL context.
    // The reader uses this to decode the focused page sharper on capable GPUs.
    // Any failure returns the safe cross-platform floor (4096); the value is
    // cached on the Dart side so this one-shot probe runs at most once per device.
    private fun probeMaxTextureSize(): Int {
        val fallback = 4096
        var display: EGLDisplay? = null
        var context: EGLContext? = null
        var surface: EGLSurface? = null
        try {
            display = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
            if (display == EGL14.EGL_NO_DISPLAY) return fallback
            val ver = IntArray(2)
            if (!EGL14.eglInitialize(display, ver, 0, ver, 1)) return fallback
            val configAttribs = intArrayOf(
                EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
                EGL14.EGL_SURFACE_TYPE, EGL14.EGL_PBUFFER_BIT,
                EGL14.EGL_NONE,
            )
            val configs = arrayOfNulls<EGLConfig>(1)
            val numConfigs = IntArray(1)
            if (!EGL14.eglChooseConfig(
                    display, configAttribs, 0, configs, 0, 1, numConfigs, 0,
                ) || numConfigs[0] == 0
            ) {
                return fallback
            }
            val config = configs[0] ?: return fallback
            val contextAttribs =
                intArrayOf(EGL14.EGL_CONTEXT_CLIENT_VERSION, 2, EGL14.EGL_NONE)
            context = EGL14.eglCreateContext(
                display, config, EGL14.EGL_NO_CONTEXT, contextAttribs, 0,
            )
            if (context == EGL14.EGL_NO_CONTEXT) return fallback
            val surfaceAttribs =
                intArrayOf(EGL14.EGL_WIDTH, 1, EGL14.EGL_HEIGHT, 1, EGL14.EGL_NONE)
            surface = EGL14.eglCreatePbufferSurface(display, config, surfaceAttribs, 0)
            if (surface == EGL14.EGL_NO_SURFACE) return fallback
            if (!EGL14.eglMakeCurrent(display, surface, surface, context)) return fallback
            val maxSize = IntArray(1)
            GLES20.glGetIntegerv(GLES20.GL_MAX_TEXTURE_SIZE, maxSize, 0)
            return if (maxSize[0] >= 1024) maxSize[0] else fallback
        } catch (e: Exception) {
            return fallback
        } finally {
            if (display != null && display != EGL14.EGL_NO_DISPLAY) {
                EGL14.eglMakeCurrent(
                    display, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE,
                    EGL14.EGL_NO_CONTEXT,
                )
                if (surface != null && surface != EGL14.EGL_NO_SURFACE) {
                    EGL14.eglDestroySurface(display, surface)
                }
                if (context != null && context != EGL14.EGL_NO_CONTEXT) {
                    EGL14.eglDestroyContext(display, context)
                }
                EGL14.eglTerminate(display)
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
