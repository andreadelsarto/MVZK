import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'dart:math';
import 'dart:typed_data';

class PlayerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> audioFiles;
  final int initialIndex;

  const PlayerScreen({super.key, required this.audioFiles, required this.initialIndex});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer _audioPlayer;
  late int _currentIndex;
  double _volume = 0.5;
  bool _isPlaying = false;
  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;
  Uint8List? _albumArt;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentIndex = widget.initialIndex;
    _audioPlayer.setVolume(_volume);
    _playCurrent();
    _audioPlayer.playingStream.listen((isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    });
    _audioPlayer.shuffleModeEnabledStream.listen((isShuffle) {
      setState(() {
        _isShuffle = isShuffle;
      });
    });
    _audioPlayer.loopModeStream.listen((loopMode) {
      setState(() {
        _loopMode = loopMode;
      });
    });
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });
    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _totalDuration = duration ?? Duration.zero;
      });
    });
  }

  void _playCurrent() async {
    await _audioPlayer.setFilePath(widget.audioFiles[_currentIndex]['data']);
    _fetchAlbumArt(widget.audioFiles[_currentIndex]['data']);
    _audioPlayer.play();
    setState(() {});
  }

  void _playNext() {
    if (_isShuffle) {
      _currentIndex = Random().nextInt(widget.audioFiles.length);
    } else if (_currentIndex < widget.audioFiles.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0; // Ricomincia da capo se siamo alla fine della lista
    }
    _playCurrent();
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = widget.audioFiles.length - 1; // Torna all'ultima canzone se siamo all'inizio della lista
    }
    _playCurrent();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
    _audioPlayer.setShuffleModeEnabled(_isShuffle);
  }

  void _toggleRepeat() {
    if (_loopMode == LoopMode.off) {
      _audioPlayer.setLoopMode(LoopMode.one);
    } else if (_loopMode == LoopMode.one) {
      _audioPlayer.setLoopMode(LoopMode.all);
    } else {
      _audioPlayer.setLoopMode(LoopMode.off);
    }
  }

  void _fetchAlbumArt(String filePath) async {
    final tagger = Audiotagger();
    Tag? tag = await tagger.readTags(path: filePath);
    if (tag != null && tag.artwork != null) {
      setState(() {
        _albumArt = tag.artwork! as Uint8List?;
      });
    } else {
      setState(() {
        _albumArt = null;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = const Color(0xFFD7D8FF); // Colore di sfondo come nello screenshot

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'NOW PLAYING FROM',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              widget.audioFiles[_currentIndex]['album'] ?? 'Unknown Album',
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Menu action
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: _albumArt != null
                    ? DecorationImage(
                  image: MemoryImage(_albumArt!),
                  fit: BoxFit.cover,
                )
                    : null,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.audioFiles[_currentIndex]['title'] ?? 'Unknown Title',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    widget.audioFiles[_currentIndex]['artist'] ?? 'Unknown Artist',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Slider(
                    value: _currentPosition.inSeconds.toDouble(),
                    max: _totalDuration.inSeconds.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_currentPosition)),
                      Text(_formatDuration(_totalDuration)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color: _isShuffle ? Colors.orange : Colors.black,
                      ),
                      onPressed: _toggleShuffle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.black),
                      onPressed: _playPrevious,
                      iconSize: 64,
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.black,
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                        iconSize: 64,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.black),
                      onPressed: _playNext,
                      iconSize: 64,
                    ),
                    IconButton(
                      icon: Icon(
                        _loopMode == LoopMode.off
                            ? Icons.repeat
                            : _loopMode == LoopMode.one
                            ? Icons.repeat_one
                            : Icons.repeat,
                        color: _loopMode != LoopMode.off ? Colors.orange : Colors.black,
                      ),
                      onPressed: _toggleRepeat,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.black),
                  onPressed: () {
                    // Favorite action
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
