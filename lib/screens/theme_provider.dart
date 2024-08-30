import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color? _customAccentColor; // Colore accento personalizzato
  bool _useSystemAccentColor = true; // Di default, usa il colore accento del sistema

  ThemeMode get themeMode => _themeMode;
  Color? get customAccentColor => _customAccentColor;
  bool get useSystemAccentColor => _useSystemAccentColor;

  ThemeProvider() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeModeStr = prefs.getString('themeMode');
    int? accentColorInt = prefs.getInt('accentColor');
    bool? useSystemAccent = prefs.getBool('useSystemAccent');

    _themeMode = _getThemeModeFromString(themeModeStr ?? 'system');
    _customAccentColor = accentColorInt != null ? Color(accentColorInt) : null;
    _useSystemAccentColor = useSystemAccent ?? true;

    notifyListeners();
  }

  void setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode.toString().split('.').last);
    notifyListeners();
  }

  void setAccentColor(Color? color) async {
    _customAccentColor = color;
    _useSystemAccentColor = color == null; // Se il colore è null, usa il colore del sistema
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', color?.value ?? 0);
    await prefs.setBool('useSystemAccent', _useSystemAccentColor);
    notifyListeners();
  }

  ThemeMode _getThemeModeFromString(String themeModeStr) {
    switch (themeModeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  ColorScheme getLightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: _useSystemAccentColor ? Colors.blue : (_customAccentColor ?? Colors.blue), // Usa il colore del sistema se selezionato
      brightness: Brightness.light,
    );
  }

  ColorScheme getDarkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: _useSystemAccentColor ? Colors.blue : (_customAccentColor ?? Colors.blue), // Usa il colore del sistema se selezionato
      brightness: Brightness.dark,
    );
  }
}
