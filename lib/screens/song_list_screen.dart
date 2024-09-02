import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'image_service.dart';
import 'player_screen.dart';
import 'mini_player.dart';

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
  List<ArtistModel> _artists = [];
  List<AlbumModel> _albums = [];
  bool _isLibraryView = true;
  bool _isArtistView = false;
  bool _isAlbumView = false;
  Map<int, List<SongModel>> _albumSongs = {};
  String? _selectedArtist;
  Uint8List? _selectedArtistImage;
  Uint8List? _selectedArtistBlurredImage; // Immagine sfocata dell'artista selezionato
  List<int> _expandedAlbums = [];


  @override
  void initState() {
    super.initState();
    _fetchSongs();
    _fetchArtists();
    _fetchAlbums();
  }

  Future<void> _fetchSongs() async {
    if (await _audioQuery.permissionsStatus() == false) {
      await _audioQuery.permissionsRequest();
    }
    List<SongModel> songs = await _audioQuery.querySongs();
    setState(() {
      _songs = songs;
    });
  }

  Future<void> _fetchArtists() async {
    List<ArtistModel> artists = await _audioQuery.queryArtists();
    setState(() {
      _artists = artists;
    });
  }

  Future<void> _fetchAlbums() async {
    List<AlbumModel> albums = await _audioQuery.queryAlbums();
    setState(() {
      _albums = albums;
    });
  }

  Future<void> _fetchSongsForAlbum(int albumId) async {
    List<SongModel> songs = await _audioQuery.queryAudiosFrom(AudiosFromType.ALBUM_ID, albumId);
    setState(() {
      _albumSongs[albumId] = songs;
    });
  }

  Future<void> _fetchArtistImage(String artistName, Color accentColor) async {
    final images = await ImageService.fetchArtistImage(artistName, accentColor);
    setState(() {
      _selectedArtistImage = images['original'];
      _selectedArtistBlurredImage = images['blurred'];
    });
  }

  void _playAll(List<SongModel> songs) {
    if (songs.isNotEmpty) {
      widget.audioPlayer.setAudioSource(
        ConcatenatingAudioSource(
          children: songs.map((song) {
            return AudioSource.uri(Uri.parse(song.uri!));
          }).toList(),
        ),
      );
      widget.audioPlayer.play();
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
                onPressed: () => _playAll(_songs),
                style: ElevatedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onPrimary, backgroundColor: theme.colorScheme.primary,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffle All'),
                onPressed: () {
                  widget.audioPlayer.setShuffleModeEnabled(true);
                  _playAll(_songs);
                },
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
          if (_songs.isNotEmpty)
            MiniPlayer(audioPlayer: widget.audioPlayer, audioFiles: _songs),
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
          subtitle: Text('${artist.numberOfAlbums} album(s), ${artist.numberOfTracks} track(s)'),
          onTap: () async {
            _selectedArtist = artist.artist;
            await _fetchArtistImage(_selectedArtist!, Theme.of(context).colorScheme.primary); // Carica l'immagine sfocata
            setState(() {
              _isArtistView = false;
              _isAlbumView = true; // Cambia vista per visualizzare gli album dell'artista selezionato
            });
          },
        );
      },
    );
  }

  Widget _buildAlbumList() {
    return Stack(
      children: [
        if (_selectedArtistBlurredImage != null) // Usa l'immagine sfocata come sfondo
          Positioned.fill(
            child: Image.memory(
              _selectedArtistBlurredImage!,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _selectedArtist ?? '',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _albums.length,
                itemBuilder: (context, index) {
                  final album = _albums[index];
                  if (album.artist != _selectedArtist) return Container();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(album.album, style: TextStyle(color: Colors.white)),
                        trailing: IconButton(
                          icon: Icon(Icons.play_arrow, color: Colors.white),
                          onPressed: () {
                            _fetchSongsForAlbum(album.id).then((_) {
                              _playAll(_albumSongs[album.id]!);
                              // Aggiorna la vista del player con le canzoni dell'album
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayerScreen(
                                    audioFiles: _albumSongs[album.id]!,
                                    initialIndex: 0,
                                    audioPlayer: widget.audioPlayer,
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (_expandedAlbums.contains(album.id)) {
                              _expandedAlbums.remove(album.id);
                            } else {
                              _expandedAlbums.add(album.id);
                              if (!_albumSongs.containsKey(album.id)) {
                                _fetchSongsForAlbum(album.id);
                              }
                            }
                          });
                        },
                      ),
                      if (_expandedAlbums.contains(album.id))
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            children: (_albumSongs[album.id] ?? []).map((song) {
                              return ListTile(
                                title: Text(song.title, style: TextStyle(color: Colors.white70)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlayerScreen(
                                        audioFiles: _albumSongs[album.id]!,
                                        initialIndex: _albumSongs[album.id]!.indexOf(song),
                                        audioPlayer: widget.audioPlayer,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
