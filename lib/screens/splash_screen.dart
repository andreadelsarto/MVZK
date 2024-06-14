// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:math';
import 'home_screen.dart';
import 'package:just_audio/just_audio.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String claim;
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _setRandomClaim();
    _navigateToHome();
  }

  void _setRandomClaim() {
    List<String> claims = [
      "To move",
      "To groove",
      "To feel the beat",
      "To get loud",
      "To escape",
      "To dream",
      "To elevate",
      "To inspire",
      "To vibe",
      "Your music",
      "Your life",
      "Your soundtrack",
      "Your way",
      "The sound of you",
      "The rhythm of life",
      "And let the music play",
      "The world away",
    ];
    claim = claims[Random().nextInt(claims.length)];
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(audioPlayer: audioPlayer, claim: claim)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              claim,
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 36, // Aumenta la dimensione del testo qui
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: <Color>[Colors.red, Colors.orange, Colors.yellow],
                  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'MVZK',
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: 18, // Dimensione del testo per il logo
                color: theme.colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
