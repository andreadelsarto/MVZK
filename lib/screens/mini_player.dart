import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_screen.dart';

class MiniPlayer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final List<Map<String, dynamic>> audioFiles;

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
    _loadLastPlayedState();
    _positionSubscription = widget.audioPlayer.positionStream.listen((position) {
      setState(() {});
    });
    _playerStateSubscription = widget.audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  Future<void> _loadLastPlayedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentIndex = prefs.getInt('lastPlayedIndex') ?? 0;
    });
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
    final currentSong = widget.audioFiles[_currentIndex];

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
                Text(currentSong['title'] ?? 'Unknown Title', style: TextStyle(color: Colors.white)),
                Text(currentSong['artist'] ?? 'Unknown Artist', style: TextStyle(color: Colors.white)),
              ],
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.skip_next, color: Colors.white),
              onPressed: () {
                if (_currentIndex < widget.audioFiles.length - 1) {
                  setState(() {
                    _currentIndex++;
                  });
                  _togglePlayPause();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
