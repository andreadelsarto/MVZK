import 'package:flutter/material.dart';
import 'profile.dart'; // Assicurati di importare il file della schermata del profilo utente

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Social',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionHeader(context, 'Friends Activity'),
            _buildActivityCard(
                context,
                'Alice',
                'listened to "Blinding Lights" by The Weeknd',
                Icons.music_note
            ),
            _buildActivityCard(
                context,
                'Bob',
                'liked a playlist "Chill Vibes"',
                Icons.favorite
            ),
            _buildActivityCard(
                context,
                'Charlie',
                'commented on a post in "Rock Lovers"',
                Icons.comment
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(context, 'Groups'),
            _buildGroupCard(context, 'Rock Lovers', 'Join the discussion about rock music!'),
            _buildGroupCard(context, 'Pop Fans', 'Share your favorite pop hits!'),
            _buildGroupCard(context, 'Jazz Enthusiasts', 'Explore the world of jazz with us!'),
          ],
        ),
      ),
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

  Widget _buildActivityCard(BuildContext context, String user, String activity, IconData icon) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userName: user),
          ),
        );
      },
      child: Card(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity,
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
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, String groupName, String description) {
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
            Icon(Icons.group, size: 40, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
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
}
