import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:mzvk/screens/splash_screen.dart';
import 'package:mzvk/screens/home_screen.dart';
import 'package:mzvk/screens/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MVZK',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: themeProvider.getLightColorScheme(),
              useMaterial3: true,
              iconTheme: IconThemeData(color: themeProvider.customAccentColor ?? Colors.blue),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.customAccentColor ?? Colors.blue,
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: themeProvider.getDarkColorScheme(),
              useMaterial3: true,
              iconTheme: IconThemeData(color: themeProvider.customAccentColor ?? Colors.blue),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.customAccentColor ?? Colors.blue,
                ),
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
