import 'package:flutter/material.dart';
import 'pong_game.dart'; // Importa il gioco Pong
import 'snake_level_selection.dart'; // Importa la schermata di selezione del livello per Snake

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Games',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGameItem(context, 'Pong', PongGame()), // Aggiungi il gioco Pong
              _buildGameItem(context, 'Snake', LevelSelectionScreen()), // Modifica per utilizzare la schermata di selezione del livello
              _buildGameItem(context, 'Game 3', null),
              _buildGameItem(context, 'Game 4', null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameItem(BuildContext context, String title, Widget? game) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (game != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => game,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
