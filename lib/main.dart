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
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              ColorScheme lightColorScheme;
              ColorScheme darkColorScheme;

              if (lightDynamic != null && darkDynamic != null) {
                lightColorScheme = lightDynamic.harmonized();
                darkColorScheme = darkDynamic.harmonized();
              } else {
                lightColorScheme = ColorScheme.fromSeed(
                  seedColor: themeProvider.accentColor,
                );
                darkColorScheme = ColorScheme.fromSeed(
                  seedColor: themeProvider.accentColor,
                  brightness: Brightness.dark,
                );
              }

              return MaterialApp(
                title: 'MVZK',
                themeMode: themeProvider.themeMode,
                theme: ThemeData(
                  colorScheme: lightColorScheme,
                  useMaterial3: true,
                ),
                darkTheme: ThemeData(
                  colorScheme: darkColorScheme,
                  useMaterial3: true,
                ),
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
