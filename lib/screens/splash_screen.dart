import 'package:flutter/material.dart';
import 'dart:math';
import 'song_list_screen.dart';
import 'package:just_audio/just_audio.dart';

class SplashScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const SplashScreen({super.key, required this.audioPlayer});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String claim;

  @override
  void initState() {
    super.initState();
    _setRandomClaim();
    _navigateToSongList();
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
      // Aggiungi altri claim qui
    ];
    claim = claims[Random().nextInt(claims.length)];
  }

  _navigateToSongList() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SongListScreen(claim: claim, audioPlayer: widget.audioPlayer)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MVZK',
              style: TextStyle(
                fontSize: 36, // Aumenta la dimensione del testo qui
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 20),
            Text(
              claim,
              style: TextStyle(
                fontSize: 18, // Dimensione del testo per il claim
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
