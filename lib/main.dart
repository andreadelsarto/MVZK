import 'package:flutter/material.dart';
import 'screens/song_list_screen.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MVZK',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: const SongListScreen(),
    );
  }
}
