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
  late AnimationController _cloudAnimationController;
  bool _isMuted = false;
  bool _showIdle = false;

  late LottieComposition _initialComposition;
  late LottieComposition _idleComposition;
  bool _isCompositionLoaded = false;

  @override
  void initState() {
    super.initState();
    _playMusic();

    _initialAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _idleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _cloudAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 400),
      lowerBound: 0,
      upperBound: 1,
    );

    _loadAnimations();
    _cloudAnimationController.repeat(reverse: false);
  }

  Future<void> _loadAnimations() async {
    _initialComposition = await _loadLottieComposition('assets/Animations/animationTest1.json');
    _idleComposition = await _loadLottieComposition('assets/Animations/plant_idle.json');

    setState(() {
      _isCompositionLoaded = true;
    });

    _initialAnimationController.forward().whenComplete(() => _switchToIdle());
  }

  Future<LottieComposition> _loadLottieComposition(String path) async {
    final composition = await AssetLottie(path).load();
    return composition;
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
    _idleAnimationController.repeat();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _initialAnimationController.dispose();
    _idleAnimationController.dispose();
    _cloudAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 200;
    final screenWidth = MediaQuery.of(context).size.width;
    final groundHeight = screenHeight * 0.3;
    final groundWidth = screenWidth;
    final plantHeight = 500.0;
    final plantWidth = 500.0;
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
                      'assets/images/plant/groundWithShadow.png',
                      fit: BoxFit.fill,
                      height: groundHeight,
                      width: groundWidth,
                    ),
                  ),
                  if (_isCompositionLoaded)
                    Positioned(
                      bottom: plantBottomPosition,
                      child: Lottie(
                        composition: _showIdle ? _idleComposition : _initialComposition,
                        width: plantWidth,
                        height: plantHeight,
                        fit: BoxFit.contain,
                        controller: _showIdle ? _idleAnimationController : _initialAnimationController,
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
