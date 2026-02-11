package com.zeromedixine.app

import android.content.ContentValues
import android.content.Context
import android.media.AudioManager
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val MEDIA_CHANNEL = "media_store_channel"
    private val AUDIO_CHANNEL = "audio_control"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 🔹 Screenshot / MediaStore channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MEDIA_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "saveImage") {
                try {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName")
                    val folder = call.argument<String>("folder")

                    if (bytes == null || fileName == null || folder == null) {
                        result.error("INVALID_ARGS", "Missing arguments", null)
                        return@setMethodCallHandler
                    }

                    val contentValues = ContentValues().apply {
                        put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
                        put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                        put(
                            MediaStore.Images.Media.RELATIVE_PATH,
                            "Pictures/$folder"
                        )
                    }

                    val resolver = applicationContext.contentResolver
                    val uri = resolver.insert(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                        contentValues
                    )

                    if (uri == null) {
                        result.error("URI_ERROR", "Failed to insert MediaStore", null)
                        return@setMethodCallHandler
                    }

                    resolver.openOutputStream(uri)?.use {
                        it.write(bytes)
                    }

                    result.success(true)
                } catch (e: Exception) {
                    result.error("SAVE_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }

        // 🔹 GLOBAL MIC MUTE channel (MAIN AUDIO CONTROL)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AUDIO_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "muteMic") {
                val mute = call.argument<Boolean>("mute") ?: false

                val audioManager =
                    getSystemService(Context.AUDIO_SERVICE) as AudioManager

                audioManager.isMicrophoneMute = mute

                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}
