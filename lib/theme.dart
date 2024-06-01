import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFFC5E3C),
    scaffoldBackgroundColor: Colors.grey[200],
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.grey),
    ),
    sliderTheme: SliderThemeData(
      thumbColor: Colors.grey[200],
      activeTrackColor: const Color(0xFFFC5E3C),
      inactiveTrackColor: Colors.grey,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.orange,
      brightness: Brightness.light,
    ).copyWith(
      secondary: Colors.black, // Quadrato nero in modalità light
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFFC5E3C),
    scaffoldBackgroundColor: Colors.black,
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.grey),
    ),
    sliderTheme: const SliderThemeData(
      thumbColor: Colors.black,
      activeTrackColor: Color(0xFFFC5E3C),
      inactiveTrackColor: Colors.grey,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.orange,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: Colors.grey[300], // Quadrato grigio chiaro in modalità dark
    ),
  );
}
