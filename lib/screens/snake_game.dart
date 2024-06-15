import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() => runApp(SnakeGame());

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Snake Game',
          theme: ThemeData(
            colorScheme: lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: SnakeHome(),
        );
      },
    );
  }
}

class SnakeHome extends StatefulWidget {
  @override
  _SnakeHomeState createState() => _SnakeHomeState();
}

class _SnakeHomeState extends State<SnakeHome> {
  List<Offset> _snakePositions = [Offset.zero];
  Offset _foodPosition = Offset.zero;
  String _direction = 'up';
  int _score = 0;
  Timer? _timer;
  final _random = Random();
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _snakePositions = [Offset(10, 10)];
    _foodPosition = _generateFoodPosition();
    _direction = 'up';
    _score = 0;
    _isGameOver = false;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      setState(() {
        _moveSnake();
      });
    });
  }

  Offset _generateFoodPosition() {
    return Offset(_random.nextInt(20).toDouble(), _random.nextInt(20).toDouble());
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

      if (_checkGameOver(newHead)) {
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

  bool _checkGameOver(Offset position) {
    if (position.dx < 0 || position.dx >= 20 || position.dy < 0 || position.dy >= 20) {
      return true;
    }
    if (_snakePositions.contains(position)) {
      return true;
    }
    return false;
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
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  for (final position in _snakePositions)
                    Positioned(
                      left: position.dx * 20,
                      top: position.dy * 20,
                      child: Container(
                        width: 20,
                        height: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  Positioned(
                    left: _foodPosition.dx * 20,
                    top: _foodPosition.dy * 20,
                    child: Container(
                      width: 20,
                      height: 20,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    child: Text(
                      'Score: $_score',
                      style: TextStyle(
                        fontSize: 36,
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
                        SizedBox(width: 50),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          iconSize: 36,
                          color: theme.colorScheme.primary,
                          onPressed: () => _changeDirection('right'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 36,
                          color: theme.colorScheme.primary,
                          onPressed: () => _changeDirection('down'),
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
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
