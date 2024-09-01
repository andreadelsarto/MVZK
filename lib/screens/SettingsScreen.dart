import 'package:flutter/material.dart';
import 'theme_settings_screen.dart';
import 'sound_screen.dart'; // Importa la schermata del suono

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'settings', // Testo tutto minuscolo
          style: TextStyle(
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [
              _buildSettingsOption(context, 'theme', Icons.brightness_6, () {
                Navigator.of(context).push(_createRoute(const ThemeSettingsScreen()));
              }),
              _buildSettingsOption(context, 'sound', Icons.equalizer, () {
                Navigator.of(context).push(_createRoute(const SoundScreen()));
              }),
              _buildSettingsOption(context, 'notifications', Icons.notifications, () {
                // Logica per gestire le notifiche
              }),
              // Aggiungi altre impostazioni secondo necessità
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context, String title, IconData icon, VoidCallback onTap) {
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
                fontSize: 50, // Uniforma la dimensione del carattere a quella della home screen
              ),
            ),
          ],
        ),
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
