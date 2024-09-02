import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final String userName;

  const UserProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          '$userName\'s Profile',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 20),
            _buildSectionHeader(context, 'Public Playlists'),
            _buildPlaylistCard(context, 'Chill Vibes', 25),
            _buildPlaylistCard(context, 'Workout Mix', 15),
            _buildPlaylistCard(context, 'Favorites', 30),

            const SizedBox(height: 20),

            _buildSectionHeader(context, 'Favorite Songs'),
            _buildSongCard(context, 'Blinding Lights', 'The Weeknd'),
            _buildSongCard(context, 'Levitating', 'Dua Lipa'),
            _buildSongCard(context, 'Watermelon Sugar', 'Harry Styles'),

            const SizedBox(height: 20),

            _buildSectionHeader(context, 'Recent Activity'),
            _buildActivityCard(context, 'listened to "Shape of You" by Ed Sheeran', Icons.music_note),
            _buildActivityCard(context, 'commented on a post in "Rock Lovers"', Icons.comment),
            _buildActivityCard(context, 'added "Bohemian Rhapsody" to playlist "Rock Legends"', Icons.add),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/images/default_profile.png'), // Usa un'immagine di default o carica l'immagine dell'utente
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alice',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Music Lover',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.onBackground,
          fontSize: 30,
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(BuildContext context, String playlistName, int songCount) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.playlist_play, size: 40, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlistName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$songCount songs',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongCard(BuildContext context, String songTitle, String artistName) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.music_note, size: 40, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    songTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artistName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, String activity, IconData icon) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                activity,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
