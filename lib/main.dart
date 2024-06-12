import 'package:flutter/material.dart';
import 'package:mzvk/screens/splash_screen.dart';
import 'screens/song_list_screen.dart';
import 'theme.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final audioPlayer = AudioPlayer();
    return MaterialApp(
      title: 'MVZK',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: SplashScreen(audioPlayer: audioPlayer),
    );
  }
}
