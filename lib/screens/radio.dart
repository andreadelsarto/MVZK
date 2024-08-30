import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class RadioScreen extends StatefulWidget {
  @override
  _RadioScreenState createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Map<String, String>> _stations = [
    {
      'name': 'Jazz FM',
      'url': 'https://jazzfm-streaming-url.example.com/stream' // Sostituisci con l'URL della stazione radio
    },
    {
      'name': 'Rock Radio',
      'url': 'https://rockradio-streaming-url.example.com/stream' // Sostituisci con l'URL della stazione radio
    },
    {
      'name': 'Classical Music',
      'url': 'https://classicalmusic-streaming-url.example.com/stream' // Sostituisci con l'URL della stazione radio
    },
  ];

  String? _currentStationName;
  String? _currentStationUrl;
  bool _isPlaying = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isMinimal = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, 1),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _playStation(String name, String url) async {
    if (_currentStationUrl != url) {
      try {
        await _audioPlayer.setUrl(url);
        _audioPlayer.play();
        setState(() {
          _isPlaying = true;
          _currentStationName = name;
          _currentStationUrl = url;
        });
      } catch (e) {
        print('Errore durante la riproduzione della stazione radio: $e');
      }
    } else if (!_isPlaying) {
      _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else if (_currentStationUrl != null) {
      _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleMinimalMode() {
    setState(() {
      _isMinimal = !_isMinimal;
      if (_isMinimal) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = const Color(0xFF1C1C1C); // Colore di sfondo scuro

    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onTap: _toggleMinimalMode,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isMinimal)
                  Column(
                    children: [
                      Text(
                        _currentStationName ?? 'Seleziona una stazione',
                        style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
                      onPressed: _togglePlayPause,
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _stations.length,
                    itemBuilder: (context, index) {
                      final station = _stations[index];
                      return ListTile(
                        title: Text(
                          station['name']!,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onBackground,
                            fontSize: 24,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            _isPlaying && _currentStationUrl == station['url'] ? Icons.pause : Icons.play_arrow,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () => _playStation(station['name']!, station['url']!),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (_isMinimal)
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    color: Colors.black54,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                          onPressed: _togglePlayPause,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentStationName ?? 'Radio',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (_isPlaying)
                          IconButton(
                            icon: const Icon(Icons.stop, color: Colors.white),
                            onPressed: () {
                              _audioPlayer.stop();
                              setState(() {
                                _isPlaying = false;
                                _currentStationUrl = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
