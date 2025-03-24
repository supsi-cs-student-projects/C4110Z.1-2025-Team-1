import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Load your game assets and initialize the game here
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Render your game objects here
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update your game objects here
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game')),
      body: GameWidget(game: MyGame()),
    );
  }
}