import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'player_screen.dart';

class MiniPlayer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final List<SongModel> audioFiles;

  const MiniPlayer({super.key, required this.audioPlayer, required this.audioFiles});

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  late int _currentIndex;
  bool _isPlaying = false;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<PlayerState> _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.audioPlayer.currentIndex ?? 0;
    _loadLastPlayedState();

    _positionSubscription = widget.audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {});
      }
    });

    _playerStateSubscription = widget.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    widget.audioPlayer.currentIndexStream.listen((index) {
      if (index != null && mounted) {
        setState(() {
          _currentIndex = index;
          _saveCurrentIndex(index);
        });
      }
    });
  }

  Future<void> _loadLastPlayedState() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayedIndex = prefs.getInt('lastPlayedIndex') ?? 0;

    // Controlla se l'indice salvato è valido
    if (lastPlayedIndex >= 0 && lastPlayedIndex < widget.audioFiles.length) {
      setState(() {
        _currentIndex = lastPlayedIndex;
      });
    }
  }

  Future<void> _saveCurrentIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPlayedIndex', index);
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      widget.audioPlayer.pause();
    } else {
      widget.audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _playerStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.audioFiles.length) return SizedBox.shrink(); // Verifica dell'indice fuori limite

    final theme = Theme.of(context); // Usa il tema corrente
    final currentSong = widget.audioFiles[_currentIndex];
    final position = widget.audioPlayer.position;
    final duration = widget.audioPlayer.duration ?? Duration.zero;

    double progress = 0.0;
    if (duration.inMilliseconds > 0) {
      progress = position.inMilliseconds / duration.inMilliseconds;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              audioFiles: widget.audioFiles,
              initialIndex: _currentIndex,
              audioPlayer: widget.audioPlayer,
            ),
          ),
        );
      },
      child: Container(
        color: theme.colorScheme.primary.withOpacity(0.8), // Utilizza il colore primario del tema con opacità
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: theme.colorScheme.onPrimary),
              onPressed: _togglePlayPause,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentSong.title.length > 20
                        ? '${currentSong.title.substring(0, 20)}...'
                        : currentSong.title,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary),
                  ),
                  Text(
                    currentSong.artist ?? 'Unknown Artist',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress.isNaN ? 0.0 : progress,
                    backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: () {
                if (_currentIndex < widget.audioFiles.length - 1) {
                  final nextIndex = _currentIndex + 1;
                  widget.audioPlayer.seek(Duration.zero, index: nextIndex);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
