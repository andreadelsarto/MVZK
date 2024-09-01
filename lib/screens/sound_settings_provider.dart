// sound_settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundSettingsProvider with ChangeNotifier {
  double _crossfadeDuration = 0.0;

  double get crossfadeDuration => _crossfadeDuration;

  SoundSettingsProvider() {
    _loadSettings();
  }

  void setCrossfadeDuration(double duration) {
    _crossfadeDuration = duration;
    notifyListeners();
    _saveSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _crossfadeDuration = prefs.getDouble('crossfadeDuration') ?? 0.0;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('crossfadeDuration', _crossfadeDuration);
  }
}
