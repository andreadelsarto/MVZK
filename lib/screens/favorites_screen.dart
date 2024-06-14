import 'dart:math';
import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'player_screen.dart';

List<SongModel> favoriteSongs = [];

class FavoritesScreen extends StatelessWidget {
  final AudioPlayer audioPlayer;

  FavoritesScreen({required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2ECC71), // Colore di sfondo come nello screenshot
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Favorites', style: TextStyle(color: Colors.black)),
      ),
      body: ListView.builder(
        itemCount: favoriteSongs.length,
        itemBuilder: (context, index) {
          final song = favoriteSongs[index];
          return ListTile(
            title: Text(song.title),
            subtitle: Text(song.artist ?? 'Unknown Artist'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerScreen(
                    audioFiles: favoriteSongs,
                    initialIndex: index,
                    audioPlayer: audioPlayer,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PlayerScreen extends StatelessWidget {
  final List<SongModel> audioFiles;
  final int initialIndex;
  final AudioPlayer audioPlayer;

  PlayerScreen({
    required this.audioFiles,
    required this.initialIndex,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    // Codice del player...
    return Scaffold(
      // Implementazione dello screen del player
    );
  }
}

class SongListScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final String claim;
  final Uint8List? blurredBackgroundImage;

  const SongListScreen({
    super.key,
    required this.claim,
    required this.audioPlayer,
    this.blurredBackgroundImage,
  });

  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  bool _isLibraryView = true;
  bool _isArtistView = false;
  bool _isAlbumView = false;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  void _fetchSongs() async {
    if (await _audioQuery.permissionsStatus() == false) {
      await _audioQuery.permissionsRequest();
    }
    List<SongModel> songs = await _audioQuery.querySongs();
    List<AlbumModel> albums = await _audioQuery.queryAlbums();
    List<ArtistModel> artists = await _audioQuery.queryArtists();
    setState(() {
      _songs = songs;
      _albums = albums;
      _artists = artists;
    });
  }

  void _playAll() {
    if (_songs.isNotEmpty) {
      widget.audioPlayer.setAudioSource(
        ConcatenatingAudioSource(
          children: _songs.map((song) {
            return AudioSource.uri(Uri.parse(song.uri!));
          }).toList(),
        ),
      );
      widget.audioPlayer.play();
    }
  }

  void _shuffleAll() {
    if (_songs.isNotEmpty) {
      widget.audioPlayer.setShuffleModeEnabled(true);
      _playAll();
    }
  }

  void _changeView(String view) {
    setState(() {
      _isLibraryView = view == 'Library';
      _isArtistView = view == 'Artist';
      _isAlbumView = view == 'Album';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => _changeView('Library'),
              child: Text(
                'Library',
                style: TextStyle(
                  fontSize: 24,
                  color: _isLibraryView ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => _changeView('Artist'),
              child: Text(
                'Artist',
                style: TextStyle(
                  fontSize: 24,
                  color: _isArtistView ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => _changeView('Album'),
              child: Text(
                'Album',
                style: TextStyle(
                  fontSize: 24,
                  color: _isAlbumView ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play All'),
                onPressed: _playAll,
                style: ElevatedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onPrimary, backgroundColor: theme.colorScheme.primary,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffle All'),
                onPressed: _shuffleAll,
                style: ElevatedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onPrimary, backgroundColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLibraryView
                ? _buildSongList()
                : _isArtistView
                ? _buildArtistList()
                : _buildAlbumList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        return ListTile(
          title: Text(song.title),
          subtitle: Text(song.artist ?? 'Unknown Artist'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerScreen(
                  audioFiles: _songs,
                  initialIndex: index,
                  audioPlayer: widget.audioPlayer,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArtistList() {
    return ListView.builder(
      itemCount: _artists.length,
      itemBuilder: (context, index) {
        final artist = _artists[index];
        return ListTile(
          title: Text(artist.artist),
          onTap: () {
            // Handle artist click
          },
        );
      },
    );
  }

  Widget _buildAlbumList() {
    return ListView.builder(
      itemCount: _albums.length,
      itemBuilder: (context, index) {
        final album = _albums[index];
        return ListTile(
          title: Text(album.album),
          subtitle: Text(album.artist ?? 'Unknown Artist'),
          onTap: () {
            // Handle album click
          },
        );
      },
    );
  }
}
