import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:demo_todo_with_flutter/routes/Games.dart';
import 'package:demo_todo_with_flutter/routes/LoginPage.dart';
import 'Streak.dart';
import 'Learn.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  bool _isMuted = false;
  bool _showIdle = false; // Controlla se mostrare plant_idle

  @override
  void initState() {
    super.initState();
    _playMusic();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Durata iniziale per animationTest1
    );

    // Quando animationTest1 finisce, cambiamo animazione
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _switchToIdle();
      }
    });

    _animationController.forward();
  }

  void _playMusic() async {
    try {
      await _audioPlayer.setAsset('assets/audio/homepage_music.ogg');
      _audioPlayer.setLoopMode(LoopMode.one);
      _audioPlayer.play();
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _isMuted ? _audioPlayer.pause() : _audioPlayer.play();
    });
  }

  void _goToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _switchToIdle() {
    setState(() {
      _showIdle = true;
      _animationController.duration = const Duration(seconds: 5); // Cambia la durata per plant_idle
    });

    _animationController.reset();
    _animationController.forward(); // plant_idle deve essere ripetuta
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 30),
                  onPressed: _goToLoginPage,
                ),
                const Text(
                  'Home Page',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, size: 30),
                  onPressed: _toggleMute,
                ),
              ],
            ),
          ),

          // Animated Lottie Widget (Smooth Transition)
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ANIMAZIONE IDLE SEMPRE IN BACKGROUND
                if (_showIdle)
                  Lottie.asset(
                    'assets/Animations/plant_idle.json',
                    width: 400,
                    height: 400,
                    fit: BoxFit.contain,
                    controller: _animationController,
                    onLoaded: (composition) {
                      _animationController.duration = const Duration(seconds: 5); // plant_idle dura 5 sec
                    },
                  ),

                // ANIMAZIONE INIZIALE, SPARISCE AUTOMATICAMENTE
                if (!_showIdle)
                  Lottie.asset(
                    'assets/Animations/animationTest1.json',
                    width: 400,
                    height: 400,
                    fit: BoxFit.contain,
                    controller: _animationController,
                    onLoaded: (composition) {
                      _animationController.duration = const Duration(seconds: 2); // animationTest1 dura 2 sec
                    },
                  ),
              ],
            ),
          ),

          // Bottom Menu
          _bottomMenu(),
        ],
      ),
    );
  }

  Widget _bottomMenu() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: Colors.green[700],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomMenuButton(Icons.videogame_asset, 'Games', const Games()),
          _bottomMenuButton(Icons.add_task, 'Streak', const Streak()),
          _bottomMenuButton(Icons.explore_rounded, 'Learn', const Learn()),
        ],
      ),
    );
  }

  Widget _bottomMenuButton(IconData icon, String label, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
