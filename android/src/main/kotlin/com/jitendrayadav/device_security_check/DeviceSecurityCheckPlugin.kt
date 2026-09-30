package com.jitendrayadav.device_security_check

import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Build
import android.os.Debug
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class DeviceSecurityCheckPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "device_security_check")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "check" -> result.success(runChecks())
            else -> result.notImplemented()
        }
    }

    private fun runChecks(): Map<String, Any> {
        val suspicious = mutableListOf<String>()
        val rooted = detectRoot(suspicious)
        val developerOptions = readGlobalInt(Settings.Global.DEVELOPMENT_SETTINGS_ENABLED) == 1
        val usbDebugging = readGlobalInt(Settings.Global.ADB_ENABLED) == 1
        val emulator = detectEmulator()
        val debugger = Debug.isDebuggerConnected() || Debug.waitingForDebugger()
        val debuggable = (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0

        return mapOf(
            "supported" to true,
            "platform" to "android",
            "isCompromised" to rooted,
            "rooted" to rooted,
            "jailbroken" to false,
            "developerOptionsEnabled" to developerOptions,
            "usbDebuggingEnabled" to usbDebugging,
            "emulator" to emulator,
            "debuggerAttached" to debugger,
            "debuggableBuild" to debuggable,
            "suspiciousPathsFound" to suspicious
        )
    }

    private fun readGlobalInt(name: String): Int = try {
        Settings.Global.getInt(context.contentResolver, name, 0)
    } catch (_: Exception) {
        0
    }

    private fun detectRoot(suspicious: MutableList<String>): Boolean {
        val paths = listOf(
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/system/su",
            "/system/bin/.ext/su",
            "/system/usr/we-need-root/su-backup",
            "/system/xbin/daemonsu",
            "/su/bin/su",
            "/data/adb/magisk",
            "/data/adb/ksu",
            "/data/adb/ap",
            "/sbin/.magisk",
            "/cache/su",
            "/dev/com.koushikdutta.superuser.daemon/"
        )

        var found = false
        for (path in paths) {
            if (File(path).exists()) {
                suspicious.add(path)
                found = true
            }
        }

        val tags = Build.TAGS ?: ""
        if (tags.contains("test-keys")) {
            suspicious.add("build.tags:test-keys")
            found = true
        }

        try {
            val process = Runtime.getRuntime().exec(arrayOf("sh", "-c", "command -v su"))
            val output = process.inputStream.bufferedReader().use { it.readText() }.trim()
            if (output.isNotEmpty()) {
                suspicious.add("su:$output")
                found = true
            }
            process.destroy()
        } catch (_: Exception) {
            // Ignore: absence of command execution is not evidence of root.
        }
        return found
    }

    private fun detectEmulator(): Boolean {
        val fingerprint = Build.FINGERPRINT.lowercase()
        val model = Build.MODEL.lowercase()
        val manufacturer = Build.MANUFACTURER.lowercase()
        val brand = Build.BRAND.lowercase()
        val device = Build.DEVICE.lowercase()
        val product = Build.PRODUCT.lowercase()

        return fingerprint.contains("generic") ||
            fingerprint.contains("emulator") ||
            fingerprint.contains("vbox") ||
            model.contains("google_sdk") ||
            model.contains("emulator") ||
            model.contains("android sdk built for x86") ||
            manufacturer.contains("genymotion") ||
            (brand.startsWith("generic") && device.startsWith("generic")) ||
            product.contains("sdk") ||
            product.contains("emulator") ||
            product.contains("vbox")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
