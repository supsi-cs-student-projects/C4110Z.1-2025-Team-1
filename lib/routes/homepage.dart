import 'package:demo_todo_with_flutter/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:demo_todo_with_flutter/routes/LoginPage.dart';
import 'package:demo_todo_with_flutter/routes/Game1/higher_or_lower.dart';
import 'Streak.dart';
import 'Learn.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final authService = AuthService();
  late AnimationController _cloudAnimationController;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _playMusic();

    _cloudAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 400),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: false);
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

  void _logout() async {
    await authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _cloudAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 200;
    final screenWidth = MediaQuery.of(context).size.width;
    final groundHeight = screenHeight * 0.3;
    final plantBottomPosition = groundHeight - 110;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.logout, size: 30),
                  onPressed: _logout,
                  tooltip: "Logout",
                ),
                Text(
                  'Welcome, ${widget.username}!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, size: 30),
                  onPressed: _toggleMute,
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    child: AnimatedBuilder(
                      animation: _cloudAnimationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            (1 - _cloudAnimationController.value * screenWidth),
                            0,
                          ),
                          child: Image.asset(
                            'assets/images/plant/clouds.png',
                            fit: BoxFit.cover,
                            width: screenWidth * 4,
                            height: screenHeight,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/plant/ground.png',
                      fit: BoxFit.fill,
                      height: groundHeight,
                      width: screenWidth,
                    ),
                  ),
                  Positioned(
                    bottom: plantBottomPosition,
                    child: GestureDetector(
                      onTap: () {},


                      //loop this animation
                      child: Image.asset(
                        'assets/Animations/pixelart_test.gif',

                        width: 500,
                        height: 500,
                        fit: BoxFit.contain,
                      )

                    ),
                  ),
                ],
              ),
            ),
          ),
          _bottomMenu(),
        ],
      ),
    );
  }

  Widget _bottomMenu() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: const Color(0xFF02af5c),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomMenuButton(Icons.videogame_asset, 'Games', const GamePage()),
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
