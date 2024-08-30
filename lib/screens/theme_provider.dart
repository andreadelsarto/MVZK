import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = Colors.blue; // Colore accento di default

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  ThemeProvider() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeModeStr = prefs.getString('themeMode');
    int? accentColorInt = prefs.getInt('accentColor');

    _themeMode = _getThemeModeFromString(themeModeStr ?? 'system');
    _accentColor = accentColorInt != null ? Color(accentColorInt) : Colors.blue;

    notifyListeners(); // Notifica le modifiche agli ascoltatori
  }

  void setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode.toString().split('.').last);
    notifyListeners();
  }

  void setAccentColor(Color color) async {
    _accentColor = color;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', color.value);
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
}
