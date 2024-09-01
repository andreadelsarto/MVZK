import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:on_audio_query/on_audio_query.dart';
import 'image_service.dart';
import 'artist_info_screen.dart';
import 'song_list_screen.dart';
import 'share_screen.dart';
import 'sound_screen.dart';

List<SongModel> favoriteSongs = [];

class PlayerScreen extends StatefulWidget {
  final List<SongModel> audioFiles;
  final int initialIndex;
  final AudioPlayer audioPlayer;

  const PlayerScreen({super.key, required this.audioFiles, required this.initialIndex, required this.audioPlayer});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin {
  late int _currentIndex;
  double _volume = 0.5;
  bool _isPlaying = false;
  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;
  Uint8List? _albumArt;
  Uint8List? _artistImage;
  Uint8List? _blurredArtistImage;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late AnimationController _animationController;
  late AnimationController _textAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  bool _isMinimal = false;
  Color? _previousAccentColor;

  late StreamSubscription<bool> _playingSubscription;
  late StreamSubscription<bool> _shuffleSubscription;
  late StreamSubscription<LoopMode> _loopModeSubscription;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration?> _durationSubscription;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    widget.audioPlayer.setVolume(_volume);

    _playingSubscription = widget.audioPlayer.playingStream.listen((isPlaying) {
      if (mounted) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    });

    _shuffleSubscription = widget.audioPlayer.shuffleModeEnabledStream.listen((isShuffle) {
      if (mounted) {
        setState(() {
          _isShuffle = isShuffle;
        });
      }
    });

    _loopModeSubscription = widget.audioPlayer.loopModeStream.listen((loopMode) {
      if (mounted) {
        setState(() {
          _loopMode = loopMode;
        });
      }
    });

    _positionSubscription = widget.audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _durationSubscription = widget.audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration ?? Duration.zero;
        });
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
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

    _textSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1), // Entrata dal basso
      end: Offset(0, 0), // Posizione finale
    ).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inizializzazione basata sul contesto
    _playCurrent();  // Spostato qui per utilizzare Theme.of(context) correttamente
  }

  void _playNext() async {
    print('Playing next track'); // Log
    _textAnimationController.reverse(from: 1.0); // Anima l'uscita del testo attuale

    await Future.delayed(const Duration(milliseconds: 500)); // Attendi che l'animazione sia completa

    // Logica per selezionare la prossima traccia
    if (_isShuffle) {
      int nextIndex;
      do {
        nextIndex = Random().nextInt(widget.audioFiles.length);
      } while (nextIndex == _currentIndex); // Evita di ripetere la stessa traccia
      _currentIndex = nextIndex;
    } else {
      if (_currentIndex < widget.audioFiles.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    }

    print('Next track index: $_currentIndex, Title: ${widget.audioFiles[_currentIndex].title}'); // Log

    await widget.audioPlayer.setAudioSource(
      AudioSource.uri(Uri.parse(widget.audioFiles[_currentIndex].uri!)),
    );
    widget.audioPlayer.play();

    // Aggiorna le informazioni per la nuova traccia
    setState(() {
      _fetchAlbumArt(widget.audioFiles[_currentIndex].data);
      _updateArtistImage(Theme.of(context).colorScheme.primary);
    });

    // Anima l'ingresso del nuovo testo
    _textAnimationController.forward(from: 0.0);
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      widget.audioPlayer.pause();
    } else {
      widget.audioPlayer.play();
    }
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
    widget.audioPlayer.setShuffleModeEnabled(_isShuffle);
  }

  void _toggleRepeat() {
    if (_loopMode == LoopMode.off) {
      widget.audioPlayer.setLoopMode(LoopMode.one);
    } else if (_loopMode == LoopMode.one) {
      widget.audioPlayer.setLoopMode(LoopMode.all);
    } else {
      widget.audioPlayer.setLoopMode(LoopMode.off);
    }
  }

  void _toggleFavorite() {
    final currentSong = widget.audioFiles[_currentIndex];
    if (favoriteSongs.any((song) => song.data == currentSong.data)) {
      setState(() {
        favoriteSongs.removeWhere((song) => song.data == currentSong.data);
      });
    } else {
      setState(() {
        favoriteSongs.add(currentSong);
      });
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.playlist_add),
                title: Text('Aggiungi alla playlist'),
                onTap: () {
                  // Gestisci l'aggiunta alla playlist
                },
              ),
              ListTile(
                leading: Icon(Icons.album),
                title: Text('Visualizza album'),
                onTap: () {
                  // Gestisci la visualizzazione dell'album
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Visualizza artista'),
                onTap: () {
                  // Gestisci la visualizzazione dell'artista
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Condividi'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShareScreen(
                        image: _blurredArtistImage!,
                        artistName: widget.audioFiles[_currentIndex].artist ?? 'Unknown Artist',
                        songTitle: widget.audioFiles[_currentIndex].title,
                        accentColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Info artista'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistInfoScreen(
                        artistName: widget.audioFiles[_currentIndex].artist ?? 'Unknown Artist',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _playPrevious() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = widget.audioFiles.length - 1;
      }
    });
    _playCurrent();
  }

  void _playCurrent() async {
    if (widget.audioPlayer.currentIndex != _currentIndex) {
      await widget.audioPlayer.setAudioSource(
        ConcatenatingAudioSource(
          children: widget.audioFiles.map((song) {
            return AudioSource.uri(Uri.parse(song.uri!));
          }).toList(),
        ),
        initialIndex: _currentIndex,
      );
      widget.audioPlayer.play();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAlbumArt(widget.audioFiles[_currentIndex].data);
      _updateArtistImage(Theme.of(context).colorScheme.primary);
    });
  }

  Future<void> _fetchArtistImage(String artist, Color accentColor) async {
    final images = await ImageService.fetchArtistImage(artist, accentColor);
    if (images['original'] != null && images['blurred'] != null) {
      if (mounted) {
        setState(() {
          _artistImage = images['original'];
          _blurredArtistImage = images['blurred'];
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _artistImage = null;
          _blurredArtistImage = null;
        });
      }
    }
  }

  void _updateArtistImage(Color accentColor) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchArtistImage(
        widget.audioFiles[_currentIndex].artist ?? 'Unknown Artist',
        accentColor,
      );
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _fetchAlbumArt(String filePath) async {
    final tagger = Audiotagger();
    Tag? tag = await tagger.readTags(path: filePath);
    if (tag != null && tag.artwork != null) {
      if (mounted) {
        setState(() {
          _albumArt = tag.artwork! as Uint8List?;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _albumArt = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _playingSubscription.cancel();
    _shuffleSubscription.cancel();
    _loopModeSubscription.cancel();
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _animationController.dispose();
    _textAnimationController.dispose();
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
    final backgroundColor = const Color(0xFF1C1C1C);
    final currentSong = widget.audioFiles[_currentIndex];
    final isFavorite = favoriteSongs.any((song) => song.data == currentSong.data);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          if (_blurredArtistImage != null)
            Positioned.fill(
              child: Image.memory(
                _blurredArtistImage!,
                fit: BoxFit.cover,
                color: Colors.black45,
                colorBlendMode: BlendMode.darken,
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visualizza la prossima canzone
                    Align(
                      alignment: Alignment.topRight,
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textAnimationController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Next song:',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                              ),
                              Text(
                                _getNextSongTitle(),
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                              ),
                              Text(
                                _getNextArtistName(),
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! < 0) {
                          _playNext();
                        } else if (details.primaryVelocity! > 0) {
                          _playPrevious();
                        }
                      },
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textAnimationController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.title,
                                style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                currentSong.artist ?? 'Unknown Artist',
                                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.white38,
                      value: _currentPosition.inSeconds.toDouble(),
                      min: 0.0,
                      max: _totalDuration.inSeconds.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          widget.audioPlayer.seek(Duration(seconds: value.toInt()));
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_currentPosition), style: TextStyle(color: Colors.white)),
                          Text(_formatDuration(_totalDuration), style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.skip_previous, color: Colors.white),
                          onPressed: _playPrevious,
                        ),
                        IconButton(
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
                          onPressed: _togglePlayPause,
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_next, color: Colors.white),
                          onPressed: _playNext,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(_isShuffle ? Icons.shuffle_on : Icons.shuffle, color: Colors.white),
                          onPressed: _toggleShuffle,
                        ),
                        IconButton(
                          icon: Icon(
                              _loopMode == LoopMode.one
                                  ? Icons.repeat_one
                                  : (_loopMode == LoopMode.all ? Icons.repeat : Icons.repeat),
                              color: Colors.white),
                          onPressed: _toggleRepeat,
                        ),
                        IconButton(
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                          onPressed: _toggleFavorite,
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () => _showBottomSheet(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          if (_isMinimal)
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
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
                            Text(currentSong.title, style: const TextStyle(color: Colors.white)),
                            Text(currentSong.artist ?? 'Unknown Artist', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white),
                          onPressed: _playNext,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () => _playPrevious(),
              child: Container(
                width: 40,
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () => _playNext(),
              child: Container(
                width: 40,
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextSongTitle() {
    if (_isShuffle) {
      int nextIndex = (_currentIndex + 1) % widget.audioFiles.length;
      return widget.audioFiles[nextIndex].title;
    } else if (_currentIndex < widget.audioFiles.length - 1) {
      return widget.audioFiles[_currentIndex + 1].title;
    } else {
      return widget.audioFiles[0].title;
    }
  }

  String _getNextArtistName() {
    if (_isShuffle) {
      int nextIndex = (_currentIndex + 1) % widget.audioFiles.length;
      return widget.audioFiles[nextIndex].artist ?? 'Unknown Artist';
    } else if (_currentIndex < widget.audioFiles.length - 1) {
      return widget.audioFiles[_currentIndex + 1].artist ?? 'Unknown Artist';
    } else {
      return widget.audioFiles[0].artist ?? 'Unknown Artist';
    }
  }
}
