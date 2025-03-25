import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class TappableRectangle extends RectangleComponent with TapCallbacks {
  final VoidCallback onTap;

  TappableRectangle({
    required Vector2 position,
    required Vector2 size,
    required Color color,
    required this.onTap,
  }) : super(
    position: position,
    size: size,
    paint: Paint()..color = color,
  );

  @override
  void onTapUp(TapUpEvent event) {
    onTap();
  }
}

class RoundedRectangleComponent extends PositionComponent {
  final double radius;
  final Paint paint;

  RoundedRectangleComponent({
    required Vector2 size,
    required this.radius,
    required Color color,
  })  : paint = Paint()..color = color,
        super(size: size);

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      Radius.circular(radius),
    );
    canvas.drawRRect(rect, paint);
  }
}

class HigherOrLowerGame extends FlameGame with TapCallbacks {
  late TappableRectangle _leftRectangle;
  late RectangleComponent _rightRectangle;
  late TextComponent _scoreText;
  int _score = 0;

  @override
  Future<void> onLoad() async {
    _leftRectangle = TappableRectangle(
      position: Vector2(0, 0),
      size: Vector2(size.x / 2, size.y),
      color: Colors.blue,
      onTap: decreaseScore,
    );
    add(_leftRectangle);

    _rightRectangle = RectangleComponent(
      position: Vector2(size.x / 2, 0),
      size: Vector2(size.x / 2, size.y),
      paint: Paint()..color = Colors.red,
      children: [
        ButtonComponent(
          position: Vector2(10, 10),
          size: Vector2(100, 50),
          onPressed: increaseScore,
          button: RoundedRectangleComponent(
            size: Vector2(100, 50),
            radius: 50,
            color: Colors.white,
          ),
          children: [
            TextComponent(
              text: 'Tap me',
              position: Vector2(25, 15),
              textRenderer: TextPaint(
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
    add(_rightRectangle);

    _scoreText = TextComponent(
      text: 'Score: $_score',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
    add(_scoreText);
  }

  void increaseScore() {
    _score++;
    _scoreText.text = 'Score: $_score';
  }

  void decreaseScore() {
    _score--;
    _scoreText.text = 'Score: $_score';
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Higher or Lower')),
      body: GameWidget(game: HigherOrLowerGame()),
    );
  }
}
