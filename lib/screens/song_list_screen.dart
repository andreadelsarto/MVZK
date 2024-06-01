import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'player_screen.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  List<Map<String, dynamic>> _songs = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
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
      });
    } on PlatformException catch (e) {
      print("Failed to get songs: '${e.message}'.");
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Azione per il pulsante di ricerca
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
              title: const Text('MVZK to the Beats'),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              centerTitle: false,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                if (index >= _songs.length) return null;
                final song = _songs[index];
                return ListTile(
                  title: Text(song['title'] ?? 'Unknown Title'),
                  subtitle: Text(song['artist'] ?? 'Unknown Artist'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(
                          audioFiles: _songs,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: _songs.length,
            ),
          ),
        ],
      ),
    );
  }
}
