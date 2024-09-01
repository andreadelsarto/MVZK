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
  final AudioPlayer audioPlayer = AudioPlayer();

  double _crossfadeDuration = 2.0;
  bool _isVolumeNormalizationEnabled = false;

  Map<String, List<double>> equalizerPresets = {
    'Normal': [0.0, 0.0, 0.0, 0.0, 0.0],
    'Pop': [2.0, 1.0, 0.0, 1.0, 2.0],
    'Rock': [3.0, 2.0, 0.0, 2.0, 3.0],
    'Jazz': [1.0, 0.5, 0.0, 0.5, 1.0],
    'Classical': [0.0, 1.0, 3.0, 1.0, 0.0],
    'Custom': [], // Verrà caricato dalle preferenze
  };

  List<double> _currentEqualizerSettings = [0.0, 0.0, 0.0, 0.0, 0.0];
  String _currentPreset = 'Normal';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _crossfadeDuration = prefs.getDouble('crossfadeDuration') ?? 2.0;
      _isVolumeNormalizationEnabled = prefs.getBool('volumeNormalization') ?? false;
      _currentPreset = prefs.getString('equalizerPreset') ?? 'Normal';

      if (_currentPreset == 'Custom') {
        List<double> customSettings = prefs.getStringList('customEqualizerSettings')?.map((e) => double.parse(e)).toList() ?? [0.0, 0.0, 0.0, 0.0, 0.0];
        _currentEqualizerSettings = customSettings;
        equalizerPresets['Custom'] = customSettings;
      } else {
        _currentEqualizerSettings = equalizerPresets[_currentPreset]!;
      }
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

  Future<void> _saveEqualizerPreset(String preset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equalizerPreset', preset);
  }

  Future<void> _saveCustomEqualizerSettings(List<double> settings) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> settingsAsString = settings.map((e) => e.toString()).toList();
    await prefs.setStringList('customEqualizerSettings', settingsAsString);
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
          'Sound',
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
              'Audio Settings',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onBackground,
                fontSize: 50,
              ),
            ),
            const SizedBox(height: 20),
            _buildSoundOption(
              context,
              'Crossfade',
              'Fade between songs',
              Icons.swap_horiz,
                  () => _showCrossfadeBottomSheet(context),
            ),
            _buildSoundOption(
              context,
              'Equalizer',
              'Adjust sound frequencies',
              Icons.equalizer,
                  () => _showEqualizerBottomSheet(context),
            ),
            _buildSoundOption(
              context,
              'Bass Boost',
              'Enhance low frequencies',
              Icons.surround_sound,
                  () => _showBassBoostBottomSheet(context),
            ),
            _buildSoundOption(
              context,
              'Volume Normalization',
              'Normalize volume level',
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
                  title,
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

  void _showCrossfadeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Crossfade Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
        );
      },
    );
  }

  void _showEqualizerBottomSheet(BuildContext context) {
    List<double> equalizerValues = List.from(_currentEqualizerSettings);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Equalizer Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  DropdownButton<String>(
                    value: _currentPreset,
                    items: [
                      ...equalizerPresets.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key),
                        );
                      }).toList(),
                      if (!_currentPresetIsInPresets()) // Aggiungi solo se 'Custom' non è già presente
                        DropdownMenuItem<String>(
                          value: 'Custom',
                          child: Text('Custom'),
                        ),
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        _currentPreset = value!;
                        if (_currentPreset != 'Custom') {
                          // Aggiorna i valori degli slider in base al preset selezionato
                          for (int i = 0; i < equalizerValues.length; i++) {
                            equalizerValues[i] = equalizerPresets[_currentPreset]![i];
                          }
                          _saveEqualizerPreset(_currentPreset);
                        } else {
                          // Carica le impostazioni personalizzate se 'Custom' è selezionato
                          _loadCustomEqualizerSettings();
                        }
                      });
                    },
                  ),
                  ...List.generate(equalizerValues.length, (index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: _currentEqualizerSettings[index],
                        end: equalizerValues[index],
                      ),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Slider(
                          min: -10.0,
                          max: 10.0,
                          value: value,
                          onChanged: (newValue) {
                            setState(() {
                              _currentEqualizerSettings[index] = newValue;
                              equalizerValues[index] = newValue; // Aggiorna immediatamente
                              _currentPreset = 'Custom'; // Imposta il preset su 'Custom'
                              _saveCustomEqualizerSettings(equalizerValues); // Salva il preset personalizzato
                            });
                          },
                          divisions: 20,
                          label: '${value.toStringAsFixed(1)} dB',
                        );
                      },
                    );
                  }),
                ],
              );
            },
          ),
        );
      },
    );
  }

// Funzione di supporto per verificare se il preset corrente è nei preset predefiniti
  bool _currentPresetIsInPresets() {
    return equalizerPresets.containsKey(_currentPreset);
  }

// Carica le impostazioni personalizzate salvate
  void _loadCustomEqualizerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    List<double> customSettings = prefs.getStringList('customEqualizerSettings')?.map((e) => double.parse(e)).toList() ?? [0.0, 0.0, 0.0, 0.0, 0.0];
    setState(() {
      _currentEqualizerSettings = customSettings;
    });
  }


  void _showBassBoostBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bass Boost Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('Control for enhancing bass frequencies will be here.'),
              // Aggiungi qui il controllo per il potenziamento dei bassi
            ],
          ),
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
