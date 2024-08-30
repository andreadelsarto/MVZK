import 'package:flutter/material.dart';
import 'dart:async';

class PongGame extends StatefulWidget {
  @override
  _PongGameState createState() => _PongGameState();
}

class _PongGameState extends State<PongGame> {
  double paddleWidth = 100;
  double paddleHeight = 20;
  double ballSize = 20;
  double paddleX = 0;
  double ballX = 0;
  double ballY = 0;
  double ballSpeedX = 3;
  double ballSpeedY = 3;
  int score = 0;
  int lives = 3;
  Timer? timer;
  double screenWidth = 0;
  double screenHeight = 0;
  Color? ballColor;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    timer = Timer.periodic(Duration(milliseconds: 8), (Timer timer) {
      setState(() {
        ballX += ballSpeedX;
        ballY += ballSpeedY;

        // Controllo collisioni con i muri
        if (ballX <= 0 || ballX + ballSize >= screenWidth) {
          ballSpeedX = -ballSpeedX;
        }
        if (ballY <= 0) {
          ballSpeedY = -ballSpeedY;
        }
        if (ballY + ballSize >= screenHeight) {
          // La palla ha toccato il fondo dello schermo, perdi una vita
          lives--;
          if (lives == 0) {
            // Gioco finito
            timer.cancel();
            showGameOverDialog();
          } else {
            // Reset della posizione della palla
            ballX = screenWidth / 2 - ballSize / 2;
            ballY = screenHeight / 2 - ballSize / 2;
            ballSpeedY = -ballSpeedY; // Inverti direzione della palla
          }
        }

        // Controllo collisioni con il paddle
        if (ballY + ballSize >= screenHeight - paddleHeight &&
            ballX + ballSize >= paddleX &&
            ballX <= paddleX + paddleWidth) {
          ballSpeedY = -ballSpeedY;
          score++;
          if (score % 10 == 0) {
            // Aumenta la velocità della palla ogni 10 punti
            ballSpeedX *= 1.1;
            ballSpeedY *= 1.1;
          }
        }
      });
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Over',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Score: $score',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  resetGame();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onPrimary,
                  backgroundColor: theme.colorScheme.primary,
                ),
                child: Text('Restart'),
              ),
            ],
          ),
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      lives = 3;
      score = 0;
      ballX = screenWidth / 2 - ballSize / 2;
      ballY = screenHeight / 2 - ballSize / 2;
      ballSpeedX = 3;
      ballSpeedY = 3;
    });
    startGame();
  }

  void movePaddle(DragUpdateDetails update) {
    setState(() {
      paddleX += update.delta.dx;
      if (paddleX < 0) paddleX = 0;
      if (paddleX + paddleWidth > screenWidth) paddleX = screenWidth - paddleWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    ballColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onPanUpdate: (update) => movePaddle(update),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: paddleX,
            child: Container(
              width: paddleWidth,
              height: paddleHeight,
              color: Colors.blue,
            ),
          ),
          Positioned(
            top: ballY,
            left: ballX,
            child: Container(
              width: ballSize,
              height: ballSize,
              decoration: BoxDecoration(
                color: ballColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              'Score: $score',
              style: TextStyle(
                fontSize: 36,
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Row(
              children: List.generate(
                lives,
                    (index) => Icon(Icons.favorite, color: Colors.red, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
