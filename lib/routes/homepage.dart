import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // Import just_audio
import 'Streak.dart';
import 'Learn.dart';
import 'package:demo_todo_with_flutter/routes/Games.dart';
import 'package:demo_todo_with_flutter/routes/LoginPage.dart'; // Import LoginPage
import 'package:lottie/lottie.dart'; // flutter pub add lottie

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false; // Track mute state
  bool _showImage = false; // Track whether to show image or animation

  @override
  void initState() {
    super.initState();
    _playMusic();
    _startAnimation();
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

  void _startAnimation() {
    // After 5 seconds (or the duration of your animation), show the image
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showImage = true; // Change to show the image after the animation
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 30), // Back arrow
                  onPressed: _goToLoginPage, // Go back to login
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text(
                    'Home Page',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        size: 30,
                      ),
                      onPressed: _toggleMute,
                    ),
                    IconButton(
                      icon: const Icon(Icons.help_outline, size: 30),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Show animation or image based on _showImage state
          Expanded(
            child: _showImage
                ? Image.asset(
              'assets/images/plant/plant_happy.png',
              alignment: const Alignment(0.0, 0.4),
              width: 400,
              height: 400,
              fit: BoxFit.contain,
            )
                : Lottie.asset(
              'assets/Animations/animationTest1.json',
              alignment: const Alignment(0.0, 0.4),
              width: 400,
              height: 400,

              fit: BoxFit.contain,
            ),
          ),

          // Bottom menu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            color: Colors.green[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bottomMenuButton(context, Icons.videogame_asset, 'Games', const Games()),
                _bottomMenuButton(context, Icons.add_task, 'Streak', const Streak()),
                _bottomMenuButton(context, Icons.explore_rounded, 'Learn', const Learn()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomMenuButton(BuildContext context, IconData icon, String label, Widget? page) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => page));
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
