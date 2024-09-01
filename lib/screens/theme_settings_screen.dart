import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'theme settings', // Testo tutto in minuscolo
          style: TextStyle(
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'choose theme', // Testo tutto in minuscolo
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onBackground,
                fontSize: 50, // Uniforma la dimensione del carattere a quella della home screen
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeOption(context, 'light', ThemeMode.light, themeProvider),
            _buildThemeOption(context, 'dark', ThemeMode.dark, themeProvider),
            _buildThemeOption(context, 'system', ThemeMode.system, themeProvider),
            const Divider(height: 40),
            Text(
              'accent color', // Testo tutto in minuscolo
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onBackground,
                fontSize: 50, // Uniforma la dimensione del carattere a quella della home screen
              ),
            ),
            const SizedBox(height: 16),
            _buildAccentColorOptions(context, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, ThemeMode themeMode, ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    return RadioListTile<ThemeMode>(
      title: Text(
        title.toLowerCase(), // Assicura che il testo sia tutto in minuscolo
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onBackground,
          fontSize: 30, // Dimensione del testo uniformata
        ),
      ),
      value: themeMode,
      groupValue: themeProvider.themeMode,
      onChanged: (ThemeMode? value) {
        themeProvider.setThemeMode(value!); // Aggiorna il tema usando il provider
      },
    );
  }

  Widget _buildAccentColorOptions(BuildContext context, ThemeProvider themeProvider) {
    final accentColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.lime,
    ];

    return Column(
      children: [
        RadioListTile<bool>(
          title: Text(
            'system', // Testo tutto in minuscolo
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 30, // Dimensione del testo uniformata
            ),
          ),
          value: true,
          groupValue: themeProvider.useSystemAccentColor,
          onChanged: (bool? value) {
            if (value != null) {
              themeProvider.setAccentColor(null); // Usa colore accento del sistema
            }
          },
        ),
        const SizedBox(height: 16), // Aggiungi uno spazio per separare le opzioni
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: accentColors.map((color) {
            return GestureDetector(
              onTap: () {
                themeProvider.setAccentColor(color); // Applica il colore accento usando il provider
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                  border: themeProvider.customAccentColor == color && !themeProvider.useSystemAccentColor
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
