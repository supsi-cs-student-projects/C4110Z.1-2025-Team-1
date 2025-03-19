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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _initialAnimationController;
  late AnimationController _idleAnimationController;
  late AnimationController _cloudAnimationController; // New controller for clouds
  bool _isMuted = false;
  bool _showIdle = false; // Controls when to show plant_idle

  @override
  void initState() {
    super.initState();
    _playMusic();

    // Animation controller for animationTest1 (Initial animation)
    _initialAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Animation controller for plant_idle (Looped animation)
    _idleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );


    // When animationTest1 finishes, switch to plant_idle
    _initialAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _switchToIdle();
      }
    });

    // Animation controller for the scrolling clouds
    _cloudAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 400), // Controls speed of scrolling
      lowerBound: 0,
      upperBound: 1,
    );

    _initialAnimationController.forward(); // Start initial animation

    _cloudAnimationController.repeat(reverse: false); // Start cloud animation
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
    });

    _idleAnimationController.repeat(); // Start looping plant_idle
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _initialAnimationController.dispose();
    _idleAnimationController.dispose();
    _cloudAnimationController.dispose(); // Dispose cloud animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 200;
    final screenWidth = MediaQuery.of(context).size.width;
    final groundHeight = screenHeight * 0.3; // Adjust this to your liking
    final groundWidth = screenWidth;
    final imagePosition = -groundHeight; // Adjust the bottom positioning
    final plantHeight = 500.0;
    final plantWidth = 500.0;
    final plantBottomPosition = groundHeight - 110; // Adjust the bottom positioning

    return Scaffold(
      body: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

          Expanded(
            child: SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [


                  //animated clouds
                  Positioned(
                    top: 0,
                    child: AnimatedBuilder(
                      animation: _cloudAnimationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            //from right to left
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




                  // Ground image (still at the bottom)
                  Positioned(
                    bottom: 0, // Position at the bottom of the screen
                    child: Image.asset(
                      'assets/images/plant/ground.png',
                      fit: BoxFit.fill, // Ensures the image scales to the width without getting cropped
                      height: groundHeight, // Use responsive height
                      width: groundWidth, // Ensure it stretches across the full width
                    ),
                  ),

                  // Idle Animation (if active)
                  if (_showIdle)
                    Positioned(
                      bottom: plantBottomPosition, // Position the animation on top of the ground
                      child: Lottie.asset(
                        'assets/Animations/plant_idle.json',
                        width: plantWidth,
                        height: plantHeight,
                        fit: BoxFit.contain,
                        controller: _idleAnimationController,
                        onLoaded: (composition) {
                          _idleAnimationController.duration = const Duration(seconds: 5);
                        },
                      ),
                    ),

                  // Initial Animation (if active)
                  if (!_showIdle)
                    Positioned(
                      bottom: plantBottomPosition, // Position the animation on top of the ground
                      child: Lottie.asset(
                        'assets/Animations/animationTest1.json',
                        width: plantWidth,
                        height: plantHeight,
                        fit: BoxFit.contain,
                        controller: _initialAnimationController,
                        onLoaded: (composition) {
                          _initialAnimationController.duration = const Duration(seconds: 2);
                        },
                      ),
                    ),
                ],
              ),
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
      color: Color(0xFF02af5c),
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
