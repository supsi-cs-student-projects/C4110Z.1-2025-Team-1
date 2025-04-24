import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:demo_todo_with_flutter/routes/account_page.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:demo_todo_with_flutter/routes/Game/higher_or_lower.dart';
import 'package:demo_todo_with_flutter/services/auth.dart';
import 'package:demo_todo_with_flutter/routes/LoginPage.dart';
import '../services/GameService.dart';
import '../services/Streak.dart';
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
  final streak = StreakService();
  final _gameService = GameService();

  late AnimationController _cloudAnimationController;
  late Future<LottieComposition> _plantAnimation;
  bool _isMuted = false;
  bool _isCuriositiesWidgetVisible = false;
  String? _randomCuriosity;

  //USER DATAS
  String? userName;
  int? streakDays;
  int? bestScore;

  //map slider values to face image asset paths
  final Map<double, String> _faceMap = {
    0.0: 'assets/images/faces/sad_face.png',
    0.5: 'assets/images/faces/normal_face.png',
    1.0: 'assets/images/faces/happy_face.png',
  };

  double _faceMood = 1.0;

  @override
  void initState() {
    super.initState();
    _isMuted = true;

    _cloudAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 600),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: false);

    _plantAnimation = _loadLottieAnimation();
    _loadUser();

    if (!_isMuted) {
      _playMusic();
    }
  }

  /// Load the current user's info from AuthService and GameService
  Future<void> _loadUser() async {
    try {
      final account = await authService.getAccount();
      final currentStreak = await streak.getStreakCount();
      final currentBest = await _gameService.getBestScore();


      setState(() {
        userName = account.name;
        streakDays = currentStreak;
        bestScore = currentBest;
      });
    } catch (e) {
      print("Failed to fetch user info: $e");
    }
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

  void _games() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HigherOrLower(username: widget.username),
      ),
    ).then((_) {
      // Refresh user info when returning
      _loadUser();
    });
  }

  Future<void> _loadRandomCuriosity() async {
    final String fileContent =
        await rootBundle.loadString('assets/infos/curiosities.txt');
    final List<String> curiosities = fileContent
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    final random = Random();
    setState(() {
      _randomCuriosity = curiosities[random.nextInt(curiosities.length)];
    });
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
    final screenWidth = MediaQuery.of(context).size.width;
    final groundHeight = screenHeight * 0.5;
    final plantBottomPosition = groundHeight * 0.18;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildBackground(screenWidth, screenHeight),
                  _buildGround(screenWidth, screenHeight),
                  _buildPlant(plantBottomPosition),
                  _buildLogOutButton(onPressed: _logout),
                  _buildHomeButton(
                    text: 'GAMES',
                    left: screenWidth * 0.05,
                    right: null,
                    bottom: groundHeight * 0.02,
                    onPressed: _games,
                  ),
                  _buildHomeButton(
                    text: 'STREAK',
                    left: null,
                    right: null,
                    bottom: groundHeight * 0.02,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StreakPage()),
                      ).then((_) => _loadUser());
                    },
                  ),
                  _buildHomeButton(
                    text: 'ACCOUNT',
                    left: null,
                    right: screenWidth * 0.05,
                    bottom: groundHeight * 0.02,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountPage(),
                        ),
                      );
                    },
                  ),
                  _buildRectangle(screenWidth, screenHeight),
                  _buildCuriositiesWidget(
                    text: 'Did you know that...',
                    imagePath: 'assets/images/curiosities/CuriosityText.png',
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  _buildInfoRectangle(
                    text: userName ?? '',
                    imagePath: 'assets/images/statistics/stats_box.png',
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              opacity: 1,
              child: Image.asset(
                'assets/images/background/background3.jpg',
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

  Widget _buildGround(double screenWidth, double screenHeight) {
    return Positioned(
      bottom: 0,
      child: Image.asset(
        'assets/images/background/new_background.png',
        fit: BoxFit.fill,
        height: screenHeight,
        width: screenWidth,
      ),
    );
  }

  Widget _buildPlant(double plantBottomPosition) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final plantWidth = screenWidth * 0.4;
    final plantHeight = screenHeight * 0.4;

    //look up the correct face image from the map
    final faceAsset = _faceMap[_faceMood]!;

    return Positioned(
      bottom: plantBottomPosition,
      child: SizedBox(
        width: plantWidth,
        height: plantHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder<LottieComposition>(
              future: _plantAnimation,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Lottie(
                    composition: snapshot.data!,
                    width: plantWidth,
                    height: plantHeight,
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            Positioned.fill(
              child: Image.asset(
                faceAsset,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(double width) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "How's your mood today?",
            style: TextStyle(
              fontSize: width * 0.06,
              fontFamily: 'RetroGaming',
              color: Colors.black,
            ),
          ),
          Slider(
            activeColor: const Color(0xFFDCAB00),
            inactiveColor: const Color(0xFF8C5261),
            value: _faceMood,
            min: 0,
            max: 1,
            divisions: 2,
            label: _faceMood == 0
                ? 'Sad'
                : _faceMood == 0.5
                    ? 'Neutral'
                    : 'Happy',
            onChanged: (value) => setState(() => _faceMood = value),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeButton({
    required String text,
    double? left,
    double? right,
    required double bottom,
    required VoidCallback onPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      bottom: bottom,
      left: left,
      right: right,
      child: SizedBox(
        width: screenWidth * 0.2,
        height: screenHeight * 0.08,
        child: CustomButton(
          text: text,
          imagePath: 'assets/images/buttons/games_button.png',
          onPressed: onPressed,
          textAlignment: Alignment.center,
          textPadding: EdgeInsets.only(bottom: screenHeight * 0.015),
          textStyle: TextStyle(
            fontSize: screenHeight * 0.02,
            color: Colors.white,
            fontFamily: 'RetroGaming',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLogOutButton({
    required VoidCallback onPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: 0.02 * screenHeight,
      left: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: Image.asset(
            'assets/images/buttons/logout_button.png',
            width: screenWidth * 0.1,
            height: screenHeight * 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildRectangle(double screenWidth, double screenHeight) {
    return Positioned(
      top: screenHeight / 3 - 20,
      left: 10,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            await _loadRandomCuriosity();
            setState(() {
              _isCuriositiesWidgetVisible = true;
            });
          },
          child: Container(
            width: screenWidth * 0.35,
            height: screenHeight * 0.5,
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCuriositiesWidget({
    required String text,
    required String imagePath,
    required double screenWidth,
    required double screenHeight,
  }) {
    if (!_isCuriositiesWidgetVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isCuriositiesWidgetVisible = false;
            });
          },
          child: Container(
            color: Colors.transparent,
            width: screenWidth,
            height: screenHeight,
          ),
        ),
        Positioned(
          top: screenHeight * 0.08,
          left: screenWidth * 0.17,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.fill,
                  width: screenWidth * 0.55,
                  height: screenHeight * 0.5,
                ),
              ),
              Positioned(
                top: screenHeight * 0.04,
                left: screenWidth * 0.1,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: screenWidth * 0.025,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'RetroGaming',
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.18,
                left: screenWidth * 0.15,
                right: screenWidth * 0.1,
                child: SizedBox(
                  width: screenWidth * 0.5,
                  child: Text(
                    _randomCuriosity ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.013,
                      color: Colors.black,
                      fontFamily: 'RetroGaming',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRectangle({
    required String text,
    required String imagePath,
    required double screenWidth,
    required double screenHeight,
  }) {
    final boxWidth = screenWidth * 0.2;
    final boxHeight = screenHeight * 0.4;
    return Positioned(
      top: screenHeight * 0.1,
      right: screenWidth * 0.05,
      child: SizedBox(
        width: boxWidth,
        height: boxHeight,
        child: Stack(
          children: [
            // --- your background image ---
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.fill,
                width: boxWidth,
                height: boxHeight,
              ),
            ),

            // --- title / name at top ---
            Positioned(
              top: boxHeight * 0.05,
              left: boxWidth * 0.05,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: boxWidth * 0.075,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RetroGaming',
                  color: Colors.black,
                ),
              ),
            ),

            // --- stats in the middle ---
            Positioned(
              top: boxHeight * 0.2,
              left: boxWidth * 0.05,
              right: boxWidth * 0.05,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: boxWidth * 0.055,
                    fontFamily: 'RetroGaming',
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Streak: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '$streakDays days\n'),
                    const TextSpan(
                      text: 'HoL best score: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '$bestScore'),
                  ],
                ),
              ),
            ),

            // --- slider at the bottom of the info box ---
            Positioned(
              bottom: boxHeight * 0.05,
              left: boxWidth * 0.05,
              right: boxWidth * 0.05,
              child: _buildSlider(boxWidth * 0.9),
            ),
          ],
        ),
      ),
    );
  }
}
