import 'package:flutter/material.dart';
import 'snake_game.dart';

class LevelSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Select Level',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLevelOption(context, 'Easy', 300),   // Velocità lenta
            _buildLevelOption(context, 'Medium', 200), // Velocità media
            _buildLevelOption(context, 'Hard', 100),   // Velocità alta
          ],
        ),
      ),
    );
  }

  Widget _buildLevelOption(BuildContext context, String title, int speed) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SnakeGame(initialSpeed: speed),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onBackground,
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}
