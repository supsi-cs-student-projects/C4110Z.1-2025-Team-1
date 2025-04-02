import 'package:demo_todo_with_flutter/routes/Game1/higher_or_lower.dart';
import 'package:demo_todo_with_flutter/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:demo_todo_with_flutter/routes/LoginPage.dart';
import 'package:lottie/lottie.dart';
import '../Homepage.dart';
import '/services/CustomButton.dart';

class HigherOrLower extends StatefulWidget {
  final String username;
  const HigherOrLower({super.key, required this.username});

  @override
  _HigherOrLowerState createState() => _HigherOrLowerState();
}

class _HigherOrLowerState extends State<HigherOrLower>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final authService = AuthService();
  late AnimationController _cloudAnimationController;
  late Future<LottieComposition> _plantAnimation;
  bool _isMuted = false;
  bool _isWindowOpen = false; // Stato della finestra (aperta o chiusa)

  @override
  void initState() {
    super.initState();
    _playMusic();

    _cloudAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 600),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: false);

    _plantAnimation = _loadLottieAnimation();
  }

  Future<LottieComposition> _loadLottieAnimation() async {
    return await AssetLottie('assets/Animations/plant_idle.json').load();
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
      MaterialPageRoute(builder: (context) => HomePage(username: widget.username)),
    );
  }

  void _games() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HigherOrLower(username: widget.username),
      ),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width + 300;
    final groundHeight = screenHeight * 0.5;
    final plantBottomPosition = groundHeight * 0.28;

    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(), // Function for the top bar
          Expanded(
            child: SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [

                  _buildBackground(screenWidth, screenHeight),


                  _buildGamesButton(screenWidth, groundHeight),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Function for the background
  Widget _buildBackground(double screenWidth, double screenHeight) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Image.asset(
        'assets/higher_or_lower/higher_or_lower_back.png',
        fit: BoxFit.fill,

        width: screenWidth,
        height: screenHeight,


        
      ),
    );
  }




// Function for the "GAMES" button
  Widget _buildGamesButton(double screenWidth, double groundHeight) {
    return Positioned(
      /*bottom: groundHeight * 0.06,
      left: screenWidth * 0.05,*/
      child: CustomButton(
        text: 'GAMES',
        imagePath: 'assets/images/buttons/games_button.png',
        onPressed: _games,
        textAlignment: Alignment.bottomRight,
        textPadding: const EdgeInsets.only(bottom: 10),
        fontFamily: 'RetroGaming',
      ),
    );
  }




// Function for the top bar
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.logout, size: 30),
            onPressed: _logout,
            tooltip: "Logout",
          ),
          IconButton(
            icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, size: 30),
            onPressed: _toggleMute,
          ),
        ],
      ),
    );
  }
}
