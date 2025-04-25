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

  // USER DATA
  String? userName;
  int? streakDays;
  int? bestScore;

  // face mood mapping
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
      print("Failed to fetch user info: \$e");
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
      print("Error loading audio: \$e");
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
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final isPortrait = media.orientation == Orientation.portrait;

    // scale based on orientation: base landscape width 1920, portrait height 1080
    final scaleFactor = isPortrait
        ? (screenHeight / 1080)
        : (screenWidth / 1920);

    double fontSize(double base) => base * scaleFactor;

    final groundHeight = screenHeight * 0.5;
    final plantBottomPosition = groundHeight * 0.18;

    //PORTRAIT
    if(isPortrait){

      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SizedBox.expand(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildBackground(screenWidth, screenHeight),
                    _buildGround(screenWidth, screenHeight, isPortrait),
                    _buildPlant(plantBottomPosition, screenWidth * 0.4),
                    _buildLogOutButton(onPressed: _logout, screenWidth: screenWidth, screenHeight: screenHeight),
                    _buildHomeButton(text: 'GAMES', left: screenWidth * 0.05, bottom: groundHeight * 0.02, onPressed: _games, scaleFactor: scaleFactor * 0.7),
                    _buildHomeButton(text: 'STREAK', bottom: groundHeight * 0.02, onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const StreakPage()),
                      ).then((_) => _loadUser());
                    }, scaleFactor: scaleFactor * 0.7),
                    _buildHomeButton(text: 'ACCOUNT', right: screenWidth * 0.05, bottom: groundHeight * 0.02, onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountPage()));
                    }, scaleFactor: scaleFactor * 0.7),
                    _buildRectangle(screenWidth, screenHeight, onTap: () async {
                      await _loadRandomCuriosity();
                      setState(() => _isCuriositiesWidgetVisible = true);
                    }),
                    _buildCuriositiesWidget(isVisible: _isCuriositiesWidgetVisible, screenWidth: screenWidth, screenHeight: screenHeight, text: 'Did you know that...', imagePath: 'assets/images/curiosities/CuriosityText.png', curiosity: _randomCuriosity, top: groundHeight * 0.3, fontSize: 10),
                    _buildInfoRectangle(username: userName ?? '', streakDays: streakDays ?? 0, bestScore: bestScore ?? 0, screenWidth: screenWidth, screenHeight: screenHeight, scaleFactor: scaleFactor * 0.8, top: screenHeight * 0.2),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

    }
    //NOT PORTRAIT
    else{
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SizedBox.expand(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildBackground(screenWidth, screenHeight),
                    _buildGround(screenWidth, screenHeight, isPortrait),
                    _buildPlant(plantBottomPosition, screenHeight * 0.4),
                    _buildLogOutButton(onPressed: _logout, screenWidth: screenWidth, screenHeight: screenHeight),
                    _buildHomeButton(text: 'GAMES', left: screenWidth * 0.05, bottom: groundHeight * 0.02, onPressed: _games, scaleFactor: scaleFactor),
                    _buildHomeButton(text: 'STREAK', bottom: groundHeight * 0.02, onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const StreakPage()),
                      ).then((_) => _loadUser());
                    }, scaleFactor: scaleFactor),
                    _buildHomeButton(text: 'ACCOUNT', right: screenWidth * 0.05, bottom: groundHeight * 0.02, onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountPage()));
                    }, scaleFactor: scaleFactor),
                    _buildRectangle(screenWidth, screenHeight, onTap: () async {
                      await _loadRandomCuriosity();
                      setState(() => _isCuriositiesWidgetVisible = true);
                    }),
                    _buildCuriositiesWidget(isVisible: _isCuriositiesWidgetVisible, screenWidth: screenWidth, screenHeight: screenHeight, text: 'Did you know that...', imagePath: 'assets/images/curiosities/CuriosityText.png', curiosity: _randomCuriosity, top: groundHeight*0.1, fontSize: 20),
                    _buildInfoRectangle(username: userName ?? '', streakDays: streakDays ?? 0, bestScore: bestScore ?? 0, screenWidth: screenWidth, screenHeight: screenHeight, scaleFactor: scaleFactor, top: screenHeight * 0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }


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
                'assets/images/background/clouds.jpg',
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

  Widget _buildGround(double w, double h, bool isPortrait) {
    return Positioned(
      bottom: 0,
      child: Image.asset(
        isPortrait
            ? 'assets/images/background/ground_vertical.png'
            : 'assets/images/background/ground_horizontal.png',
        fit: BoxFit.fill,
        width: w,
        height: h,
      ),
    );
  }

  Widget _buildPlant(double bottomPos, double plantSize) {
    final w = MediaQuery.of(context).size.width * 0.4;
    final h = MediaQuery.of(context).size.height * 0.4;
    final faceAsset = _faceMap[_faceMood]!;

    return Positioned(
      bottom: bottomPos,
      child: SizedBox(
        width:  plantSize,
        height: plantSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder<LottieComposition>(
              future: _plantAnimation,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.done && snap.hasData) {
                  return Lottie(composition: snap.data!, width: plantSize, height: plantSize);
                }
                return const CircularProgressIndicator();
              },
            ),
            Positioned.fill(child: Image.asset(faceAsset, fit: BoxFit.contain)),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(double width, {required double scaleFactor}) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("How's your mood today?", style: TextStyle(fontSize: 20*scaleFactor, fontFamily: 'RetroGaming')),
          Slider(
            activeColor: const Color(0xFFDCAB00),
            inactiveColor: const Color(0xFF8C5261),
            value: _faceMood,
            min: 0,
            max: 1,
            divisions: 2,
            label: _faceMood == 0 ? 'Sad' : _faceMood == 0.5 ? 'Neutral' : 'Happy',
            onChanged: (v) => setState(() => _faceMood = v),
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
    required double scaleFactor,
  }) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Positioned(
      bottom: bottom,
      left: left,
      right: right,
      child: SizedBox(
        width: w * 0.2,
        height: h * 0.08,
        child: CustomButton(
          text: text,
          imagePath: 'assets/images/buttons/games_button.png',
          onPressed: onPressed,
          textAlignment: Alignment.center,
          textPadding: EdgeInsets.only(bottom: h * 0.015),
          textStyle: TextStyle(
            fontSize: 22 * scaleFactor,
            color: Colors.white,
            fontFamily: 'RetroGaming',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLogOutButton({required VoidCallback onPressed, required double screenWidth, required double screenHeight}) {
    return Positioned(
      top: 0.02 * screenHeight,
      left: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: Image.asset('assets/images/buttons/logout_button.png', width: screenWidth * 0.1, height: screenHeight * 0.1),
        ),
      ),
    );
  }

  Widget _buildRectangle(double w, double h, {required VoidCallback onTap}) {
    return Positioned(
        top: h / 3 - 20,
        left: 10,
        child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: Container(width: w * 0.35, height: h * 0.5, decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)))),
    ));
  }

  Widget _buildCuriositiesWidget({
    required String text,
    required String imagePath,
    required double top,
    required double screenWidth,
    required double screenHeight, required bool isVisible, String? curiosity,
    required double fontSize,
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
          top: top,
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
                    fontSize: fontSize,
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
                    curiosity ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
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
    required String username,
    required int streakDays,
    required int bestScore,
    required double screenWidth,
    required double screenHeight,
    required double scaleFactor,
    required double top,
  }) {
    final boxW = screenWidth * 0.20;
    final boxH = screenHeight * 0.4;
    return Positioned(
      top: top,
      right: screenWidth * 0.05,
      child: SizedBox(
        width: boxW,
        height: boxH,
        child: Stack(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/statistics/stats_box.png', fit: BoxFit.fill, width: boxW, height: boxH)),
            Positioned(top: boxH*0.05, left: boxW*0.05, child: Text(username, style: TextStyle(fontSize: 25*scaleFactor, fontWeight: FontWeight.bold, fontFamily: 'RetroGaming'))),
            Positioned(
              top: boxH * 0.2,
              left: boxW * 0.05,
              right: boxW * 0.05,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20*scaleFactor,
                    fontFamily: 'RetroGaming',
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'Streak: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20*scaleFactor),
                    ),
                    TextSpan(text: '${streakDays ?? 0} days\n'),
                    TextSpan(
                      text: 'HoL best score: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20*scaleFactor),
                    ),
                    TextSpan(text: '${bestScore ?? 0}'),
                  ],
                ),
              ),
            ),
            Positioned(bottom: boxH*0.05, left: boxW*0.05, right: boxW*0.05, child: _buildSlider(boxW*0.9, scaleFactor: scaleFactor) ),
          ],
        ),
      ),
    );
  }
}