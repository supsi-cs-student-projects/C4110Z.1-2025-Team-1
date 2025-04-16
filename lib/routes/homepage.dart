import 'package:demo_todo_with_flutter/routes/Game1/higher_or_lower.dart';
import 'package:demo_todo_with_flutter/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:demo_todo_with_flutter/routes/LoginPage.dart';
import 'package:lottie/lottie.dart';
import 'Streak.dart';
import 'Learn.dart';
import '/services/CustomButton.dart';

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
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _games() async {

    //await authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HigherOrLower(username: widget.username ?? '')),
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
                  _buildGround(screenWidth, groundHeight),
                  _buildPlant(plantBottomPosition),
                  _buildGamesButton(screenWidth, groundHeight),
                  _buildStreakButton(screenWidth, groundHeight),
                  _buildAccountButton(screenWidth, groundHeight),
                  _buildCuriositiesWindow(screenWidth, screenHeight),
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
      child: AnimatedBuilder(
        animation: _cloudAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              (1 - _cloudAnimationController.value * screenWidth),
              0,
            ),
            child: Opacity(
              opacity: 0.5, // Set the desired opacity value (0.0 to 1.0)
              child: Image.asset(
                'assets/images/background/background3.png',
                fit: BoxFit.cover,
                width: screenWidth * 2.5,
                height: screenHeight,
              ),
            ),
          );
        },
      ),
    );
  }

// Function for the ground
  Widget _buildGround(double screenWidth, double groundHeight) {
    return Positioned(
      bottom: 0,
      child: Image.asset(
        'assets/images/background/new_background.png',
        fit: BoxFit.fill,
        height: groundHeight * 0.8,
        width: screenWidth,
      ),
    );
  }

// Function for the plant
  Widget _buildPlant(double plantBottomPosition) {
    return Positioned(
      bottom: plantBottomPosition,
      child: GestureDetector(
        onTap: () {},
        child: FutureBuilder<LottieComposition>(
          future: _plantAnimation,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Lottie(composition: snapshot.data!, width: 400, height: 400);
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

// Function for the "GAMES" button
  Widget _buildGamesButton(double screenWidth, double groundHeight) {
    return Positioned(
      bottom: groundHeight * 0.06,
      left: screenWidth * 0.05,
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

// Function for the "STREAK" button
  Widget _buildStreakButton(double screenWidth, double groundHeight) {
    return Positioned(
      bottom: groundHeight * 0.06,
      child: CustomButton(
        text: 'STREAK',
        imagePath: 'assets/images/buttons/games_button.png',
        onPressed: _games,
        textAlignment: Alignment.bottomRight,
        textPadding: const EdgeInsets.only(bottom: 10),
        fontFamily: 'RetroGaming',
      ),
    );
  }


// Function for the "ACCOUNT" button
  Widget _buildAccountButton(double screenWidth, double groundHeight) {
    return Positioned(
      bottom: groundHeight * 0.06,
      right: screenWidth * 0.05,
      child: CustomButton(
        text: 'ACCOUNT',
        imagePath: 'assets/images/buttons/games_button.png',
        onPressed: _games,
        textAlignment: Alignment.bottomRight,
        textPadding: const EdgeInsets.only(bottom: 10),
        fontFamily: 'RetroGaming',
      ),
    );
  }


// Function for the "Curiosities" window
  Widget _buildCuriositiesWindow(double screenWidth, double screenHeight) {
    return Positioned(
      top: screenHeight * 0.1,
      left: _isWindowOpen ? screenWidth * 0.55 : null,
      right: _isWindowOpen ? screenWidth * 0 : 0,
      child: GestureDetector(
        onTap: () {
          if (!_isWindowOpen) {
            setState(() {
              _isWindowOpen = true;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          height: _isWindowOpen ? screenHeight * 0.60 : screenHeight * 0.20,
          width: _isWindowOpen ? screenWidth * 0.7 : screenWidth * 0.025,
          padding: _isWindowOpen ? const EdgeInsets.all(20) : const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: _isWindowOpen
              ? SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Curiosities',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'RetroGaming',
                  ),

                ),
                const SizedBox(height: 10),
                const Text(
                  'Here is the curiosities window.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontFamily: 'RetroGaming',),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isWindowOpen = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    backgroundColor: const Color(0xFF18a663),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          )
              : const Center(
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                'Curiosities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'RetroGaming',),
              ),
            ),
          ),
        ),
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
          Text(
            'Welcome, ${widget.username}!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'RetroGaming',
            ),
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