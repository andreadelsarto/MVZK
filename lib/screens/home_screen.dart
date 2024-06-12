import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'song_list_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatelessWidget {
  final AudioPlayer audioPlayer;

  HomeScreen({required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Handle menu action
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'listen now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'recommended',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildRecommendedSection(),
              const SizedBox(height: 20),
              const Text(
                'history',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildHistorySection(),
              const SizedBox(height: 20),
              const Text(
                'similar songs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildSimilarSongsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildRecommendedSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 120,
              height: 120,
              color: Colors.grey[800],
              child: Center(
                child: Text(
                  'Album $index',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHistorySection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 120,
              height: 120,
              color: Colors.grey[800],
              child: Center(
                child: Text(
                  'Song $index',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSimilarSongsSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 120,
              height: 120,
              color: Colors.grey[800],
              child: Center(
                child: Text(
                  'Similar $index',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.library_music, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongListScreen(
                      claim: 'Your Claim',
                      audioPlayer: audioPlayer,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () {
                // Handle play action
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                // Handle settings action
              },
            ),
          ],
        ),
      ),
    );
  }
}
