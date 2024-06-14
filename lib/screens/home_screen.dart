import 'package:flutter/material.dart';
import 'song_list_screen.dart';
import 'package:just_audio/just_audio.dart';

class HomeScreen extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final String claim;

  const HomeScreen({super.key, required this.audioPlayer, required this.claim});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMenuItem(context, 'music', Icons.music_note, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongListScreen(
                      claim: claim,
                      audioPlayer: audioPlayer,
                    ),
                  ),
                );
              }),
              _buildMenuItem(context, 'videos', Icons.videocam, () {}),
              _buildMenuItem(context, 'pictures', Icons.photo, () {}),
              _buildMenuItem(context, 'social', Icons.people, () {}),
              _buildMenuItem(context, 'radio', Icons.radio, () {}),
              _buildMenuItem(context, 'marketplace', Icons.store, () {}),
              _buildMenuItem(context, 'games', Icons.games, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onBackground,
                fontSize: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
