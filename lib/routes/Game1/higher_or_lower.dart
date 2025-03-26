import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class HigherOrLowerGame extends FlameGame {
  RectangleComponent? _leftRectangle;
  RectangleComponent? _rightRectangle;
  late TextComponent _scoreText;
  int _score = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _setupGame();
  }

  void _setupGame() {
    final size = this.size;
    final halfWidth = size.x / 2;
    final screenHeight = size.y;

    _leftRectangle = RectangleComponent(
      position: Vector2(0, 0),
      size: Vector2(halfWidth, screenHeight),
      paint: Paint()..color = Colors.blue,
    );
    add(_leftRectangle!);

    _rightRectangle = RectangleComponent(
      position: Vector2(halfWidth, 0),
      size: Vector2(halfWidth, screenHeight),
      paint: Paint()..color = Colors.red,
    );
    add(_rightRectangle!);

    _scoreText = TextComponent(
      text: 'Score: $_score',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_scoreText);
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    _updateLayout(newSize);
  }

  void _updateLayout(Vector2 newSize) {
    if (_leftRectangle == null || _rightRectangle == null) return;

    final double halfWidth = newSize.x / 2;
    final double screenHeight = newSize.y;

    _leftRectangle!.size = Vector2(halfWidth, screenHeight);
    _rightRectangle!.position = Vector2(halfWidth, 0);
    _rightRectangle!.size = Vector2(halfWidth, screenHeight);
  }

  void increaseScore() {
    _score++;
    _scoreText.text = 'Score: $_score';
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final game = HigherOrLowerGame();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Higher or Lower'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GameWidget(
            game: game,
            mouseCursor: SystemMouseCursors.basic,
          ),
          Positioned(
            top: 20,
            right: 20,
            child: TextButton(
              onPressed: game.increaseScore,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Tap me',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
