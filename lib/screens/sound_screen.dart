import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundScreen extends StatefulWidget {
  const SoundScreen({super.key});

  @override
  _SoundScreenState createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  final AudioPlayer audioPlayer = AudioPlayer(); // Istanza di AudioPlayer

  double _crossfadeDuration = 2.0; // Valore predefinito del crossfade in secondi
  bool _isVolumeNormalizationEnabled = false; // Stato di normalizzazione del volume

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Carica il valore dal dispositivo o imposta il default a 2.0
      _crossfadeDuration = prefs.getDouble('crossfadeDuration') ?? 2.0;
      _isVolumeNormalizationEnabled = prefs.getBool('volumeNormalization') ?? false;
    });
  }

  Future<void> _saveCrossfadeDuration(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('crossfadeDuration', value);
  }

  Future<void> _saveVolumeNormalization(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('volumeNormalization', value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'sound',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'audio settings',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onBackground,
                fontSize: 50,
              ),
            ),
            const SizedBox(height: 20),
            _buildSoundOption(
              context,
              'crossfade',
              'fade between songs',
              Icons.swap_horiz,
                  () => _showCrossfadeDialog(context),
            ),
            _buildSoundOption(
              context,
              'equalizer',
              'adjust sound frequencies',
              Icons.equalizer,
                  () => _showEqualizerDialog(context),
            ),
            _buildSoundOption(
              context,
              'bass boost',
              'enhance low frequencies',
              Icons.surround_sound,
                  () => _showBassBoostDialog(context),
            ),
            _buildSoundOption(
              context,
              'volume normalization',
              'normalize volume level',
              Icons.volume_up,
                  () => _toggleVolumeNormalization(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundOption(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 30),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toLowerCase(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontSize: 30,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCrossfadeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('crossfade settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Set the crossfade duration manually between tracks.'),
              StatefulBuilder(
                builder: (context, setState) {
                  return Slider(
                    min: 0.0,
                    max: 10.0,
                    value: _crossfadeDuration,
                    onChanged: (value) {
                      setState(() {
                        _crossfadeDuration = value;
                      });
                      _saveCrossfadeDuration(value);
                    },
                    divisions: 10,
                    label: '${_crossfadeDuration.toStringAsFixed(1)} seconds',
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'),
            ),
          ],
        );
      },
    );
  }

  void _showEqualizerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('equalizer settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Equalizer settings to adjust different sound frequencies will be here.'),
              // Aggiungi qui il controllo per l'equalizzatore
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'),
            ),
          ],
        );
      },
    );
  }

  void _showBassBoostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('bass boost settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Control for enhancing bass frequencies will be here.'),
              // Aggiungi qui il controllo per il potenziamento dei bassi
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'),
            ),
          ],
        );
      },
    );
  }

  void _toggleVolumeNormalization() {
    setState(() {
      _isVolumeNormalizationEnabled = !_isVolumeNormalizationEnabled;
    });
    _saveVolumeNormalization(_isVolumeNormalizationEnabled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isVolumeNormalizationEnabled
              ? 'Volume normalization enabled'
              : 'Volume normalization disabled',
        ),
      ),
    );
  }
}
