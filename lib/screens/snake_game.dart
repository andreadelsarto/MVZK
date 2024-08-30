import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGame extends StatefulWidget {
  final int initialSpeed; // Velocità iniziale basata sul livello selezionato

  SnakeGame({required this.initialSpeed});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  List<Offset> _snakePositions = [Offset.zero];
  Offset _foodPosition = Offset.zero;
  String _direction = 'up';
  int _score = 0;
  Timer? _timer;
  final _random = Random();
  bool _isGameOver = false;
  bool _isPaused = false;
  double _gridSize = 20.0; // Dimensione di ogni cella del gioco
  late double _screenWidth;
  late double _screenHeight;
  late double _statusBarHeight;
  late double _gameAreaHeight;
  late int _speed; // Velocità di movimento del serpente

  @override
  void initState() {
    super.initState();
    _speed = widget.initialSpeed; // Imposta la velocità iniziale dal livello selezionato
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  void _initializeGame() {
    setState(() {
      _screenWidth = MediaQuery.of(context).size.width;
      _screenHeight = MediaQuery.of(context).size.height;
      _statusBarHeight = MediaQuery.of(context).padding.top;
      _gameAreaHeight = _screenHeight - _statusBarHeight - 200; // Imposta l'altezza dell'area di gioco più piccola per evitare il bordo inferiore
      _startGame();
    });
  }

  void _startGame() {
    _snakePositions = [Offset(10, 10)];
    _foodPosition = _generateFoodPosition();
    _direction = 'up';
    _score = 0;
    _isGameOver = false;
    _isPaused = false;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _speed), (timer) {
      if (!_isPaused) {
        setState(() {
          _moveSnake();
        });
      }
    });
  }

  Offset _generateFoodPosition() {
    return Offset(
      _random.nextInt((_screenWidth / _gridSize).floor()).toDouble(),
      _random.nextInt((_gameAreaHeight / _gridSize).floor()).toDouble(),
    );
  }

  void _moveSnake() {
    if (_isGameOver) return;
    setState(() {
      final head = _snakePositions.first;
      Offset newHead;

      switch (_direction) {
        case 'up':
          newHead = Offset(head.dx, head.dy - 1);
          break;
        case 'down':
          newHead = Offset(head.dx, head.dy + 1);
          break;
        case 'left':
          newHead = Offset(head.dx - 1, head.dy);
          break;
        case 'right':
          newHead = Offset(head.dx + 1, head.dy);
          break;
        default:
          newHead = head;
      }

      // Controlla se il serpente colpisce i bordi dell'area di gioco
      if (newHead.dx < 0 ||
          newHead.dx >= (_screenWidth / _gridSize).floor() ||
          newHead.dy < 0 ||
          newHead.dy >= (_gameAreaHeight / _gridSize).floor()) {
        _isGameOver = true;
        _timer?.cancel();
        _showGameOverDialog();
        return;
      }

      if (_snakePositions.contains(newHead)) {
        _isGameOver = true;
        _timer?.cancel();
        _showGameOverDialog();
        return;
      }

      _snakePositions = [newHead, ..._snakePositions];

      if (newHead == _foodPosition) {
        _score++;
        _foodPosition = _generateFoodPosition();
      } else {
        _snakePositions.removeLast();
      }
    });
  }

  void _changeDirection(String newDirection) {
    if ((_direction == 'up' && newDirection != 'down') ||
        (_direction == 'down' && newDirection != 'up') ||
        (_direction == 'left' && newDirection != 'right') ||
        (_direction == 'right' && newDirection != 'left')) {
      setState(() {
        _direction = newDirection;
      });
    }
  }

  void _showPauseMenu() {
    setState(() {
      _isPaused = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false, // L'utente non può chiudere il dialogo toccando fuori
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Paused',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onBackground,
              fontSize: 24,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.play_arrow, color: theme.colorScheme.primary),
                title: Text('Resume', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground)),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isPaused = false;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.restart_alt, color: theme.colorScheme.primary),
                title: Text('Restart', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground)),
                onTap: () {
                  Navigator.of(context).pop();
                  _startGame();
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: theme.colorScheme.primary),
                title: Text('Exit', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Your score is $_score'),
          actions: <Widget>[
            TextButton(
              child: Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        _showPauseMenu();
        return false; // Impedisce l'azione di tornare indietro finché il dialogo è aperto
      },
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: _statusBarHeight), // Lascia uno spazio per la status bar
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    // Disegna il rettangolo dell'area di gioco
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GameAreaPainter(),
                      ),
                    ),
                    // Disegna il serpente
                    for (final position in _snakePositions)
                      Positioned(
                        left: position.dx * _gridSize,
                        top: position.dy * _gridSize,
                        child: Container(
                          width: _gridSize,
                          height: _gridSize,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    // Disegna il cibo (frutto lampeggiante durante la pausa)
                    Positioned(
                      left: _foodPosition.dx * _gridSize,
                      top: _foodPosition.dy * _gridSize,
                      child: AnimatedOpacity(
                        opacity: _isPaused ? 0.0 : 1.0,
                        duration: Duration(milliseconds: 500),
                        child: Container(
                          width: _gridSize,
                          height: _gridSize,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    // Punteggio
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Text(
                        'Score: $_score',
                        style: TextStyle(
                          fontSize: 24,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: theme.colorScheme.background,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            iconSize: 36,
                            color: theme.colorScheme.primary,
                            onPressed: () => _changeDirection('up'),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            iconSize: 36,
                            color: theme.colorScheme.primary,
                            onPressed: () => _changeDirection('left'),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 36,
                            color: theme.colorScheme.primary,
                            onPressed: () => _changeDirection('down'),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward),
                            iconSize: 36,
                            color: theme.colorScheme.primary,
                            onPressed: () => _changeDirection('right'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Disegna un rettangolo attorno all'area di gioco
class GameAreaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
