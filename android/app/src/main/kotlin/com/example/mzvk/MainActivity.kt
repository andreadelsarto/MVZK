package com.example.mzvk

import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import android.provider.MediaStore
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.mzvk/music"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "getMusicFiles") {
                val musicFiles = getMusicFiles()
                result.success(musicFiles)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getMusicFiles(): List<Map<String, String>> {
        val songs = mutableListOf<Map<String, String>>()

        val contentResolver: ContentResolver = contentResolver
        val uri: Uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.DATA
        )

        val cursor: Cursor? = contentResolver.query(uri, projection, null, null, null)
        cursor?.use {
            while (it.moveToNext()) {
                val song = mapOf(
                    "title" to it.getString(it.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)),
                    "artist" to it.getString(it.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)),
                    "data" to it.getString(it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA))
                )
                songs.add(song)
            }
        }

        return songs
    }
}
