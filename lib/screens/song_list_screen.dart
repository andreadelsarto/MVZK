import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'player_screen.dart';

class SongListScreen extends StatefulWidget {
  final String claim;

  const SongListScreen({super.key, required this.claim});

  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  List<Map<String, dynamic>> _songs = [];
  List<Map<String, dynamic>> _filteredSongs = [];
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _searchController.addListener(_filterSongs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSongs);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.audio.status;
    if (status.isGranted) {
      _fetchSongs();
    } else if (status.isDenied) {
      var newStatus = await Permission.audio.request();
      if (newStatus.isGranted) {
        _fetchSongs();
      } else {
        print("Permessi non concessi");
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> _fetchSongs() async {
    const platform = MethodChannel('com.example.mzvk/music');
    try {
      final List<dynamic> songs = await platform.invokeMethod('getMusicFiles');
      setState(() {
        _songs = List<Map<String, dynamic>>.from(
            songs.map((item) => Map<String, String>.from(item)));
        _filteredSongs = _songs;
      });
    } on PlatformException catch (e) {
      print("Failed to get songs: '${e.message}'.");
    }
  }

  void _filterSongs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSongs = _songs.where((song) {
        return song['title']!.toLowerCase().contains(query) ||
            song['artist']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2ECC71), // Colore di sfondo come nello screenshot
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.black),
          onPressed: () {
            // Azione per il pulsante profilo
          },
        ),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.black),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.black, fontSize: 16.0),
        )
            : Text('MVZK ${widget.claim}'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _filteredSongs = _songs;
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              // Azione per il pulsante preferiti
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFF2ECC71),
            pinned: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('MVZK ${widget.claim}'),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              centerTitle: false,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                if (index >= _filteredSongs.length) return null;
                final song = _filteredSongs[index];
                return ListTile(
                  title: Text(song['title'] ?? 'Unknown Title'),
                  subtitle: Text(song['artist'] ?? 'Unknown Artist'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(
                          audioFiles: _filteredSongs,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: _filteredSongs.length,
            ),
          ),
        ],
      ),
    );
  }
}
