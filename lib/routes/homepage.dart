import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:demo_todo_with_flutter/routes/Game/higher_or_lower.dart';
import 'package:demo_todo_with_flutter/services/auth.dart';
import 'package:demo_todo_with_flutter/routes/LoginPage.dart';
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
  bool _isWindowOpen = false;
  bool _isCuriositiesWidgetVisible = false;
  String? _randomCuriosity;
  double _faceMood = 1; //0 sad 0.5 normal 1 happy

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

    if (!_isMuted) {
      _playMusic();
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

  void _games() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HigherOrLower(username: widget.username)),
    );
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
          _buildTopBar(), // Function for the top bar
          Expanded(
            child: SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildBackground(screenWidth, screenHeight),
                  _buildGround(screenWidth, screenHeight),
                  _buildPlant(plantBottomPosition),
                  _buildSlider(screenWidth, screenHeight),
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
                      print("Go to STREAK");
                    },
                  ),
                  _buildHomeButton(
                    text: 'ACCOUNT',
                    left: null,
                    right: screenWidth * 0.05,
                    bottom: groundHeight * 0.02,
                    onPressed: () {
                      print("Go to ACCOUNT");
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
                    text: 'Statistics',
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
    final plantWidth = screenWidth * 0.4; // 40% of width
    final plantHeight = screenHeight * 0.4; // 40% of height

    return Positioned(
      bottom: plantBottomPosition,
      child: SizedBox(
        width: plantWidth,
        height: plantHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Your existing Lottie plant:
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

            // Overlayed face image:
            Positioned.fill(
              child:
                  // adjust padding so the face sits on the plant’s head

                  Image.asset(
                _faceMood == 0
                    ? 'assets/images/faces/sad_face.png'
                    : _faceMood == 0.5
                        ? 'assets/images/faces/normal_face.png'
                        : 'assets/images/faces/happy_face.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(double screenWidth, double screenHeight) {
    return Positioned(
      right: screenWidth * 0.1,
      bottom: screenHeight * 0.32,
      child: SizedBox(
        width: screenWidth * 0.25, // Slightly wider for text
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "How's your mood today?",
              style: TextStyle(
                fontSize: screenWidth * 0.012, // Responsive font size
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
              onChanged: (value) {
                setState(() {
                  _faceMood = value;
                });
              },
            ),
          ],
        ),
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
        width: screenWidth * 0.2, // Button width is 20% of screen width
        height: screenHeight * 0.08, // Button height is 8% of screen height
        child: CustomButton(
          text: text,
          imagePath: 'assets/images/buttons/games_button.png',
          onPressed: onPressed,
          textAlignment: Alignment.center,
          textPadding: EdgeInsets.only(
              bottom: screenHeight * 0.015), // Responsive padding
          textStyle: TextStyle(
            fontSize: screenHeight * 0.02, // Font size is 4% of screen width
            color: Colors.white,
            fontFamily: 'RetroGaming',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: screenHeight * 0.02,
      left: 0,
      right: 0,
      child: SizedBox(
        width: screenWidth,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                //hex
                hoverColor: const Color(0x3825799F),
                icon: Image.asset(
                  'assets/images/buttons/logout_button.png',
                  width: screenWidth * 0.05,
                  height: screenHeight * 0.06,
                ),
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
                icon: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  size: 30,
                ),
                onPressed: _toggleMute,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRectangle(double screenWidth, double screenHeight) {
    return Positioned(
      top: screenHeight / 3 - 85,
      left: 10,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            await _loadRandomCuriosity(); // Load new curiosity
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
    if (!_isCuriositiesWidgetVisible) {
      return const SizedBox.shrink();
    }

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
          top: screenHeight * 0.02,
          left: screenWidth * 0.17,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.fill,
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.5,
                ),
              ),
              Positioned(
                top: screenHeight * 0.04,
                left: screenWidth * 0.1,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03, // responsive font size
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
                      fontSize: screenWidth * 0.015, // responsive font size
                      //fontSize: 25,
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
    return Positioned(
      top: screenHeight *
          0.1, // Posizionato leggermente sopra la metà orizzontale
      right: screenWidth * 0.05, // Posizionato sulla destra
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Immagine di sfondo
          ClipRRect(
            borderRadius: BorderRadius.circular(10), // Angoli arrotondati
            child: Image.asset(
              imagePath, // Percorso dell'immagine
              fit: BoxFit.fill, // Adatta l'immagine all'area disponibile
              width: screenWidth * 0.35, // Larghezza del rettangolo
              height: screenHeight * 0.4, // Altezza del rettangolo
            ),
          ),
          // Testo sovrapposto
          Positioned(
            top: screenHeight * 0.02, // Margine dall'alto rispetto all'immagine
            left:
                screenWidth * 0.02, // Margine da sinistra rispetto all'immagine
            child: Text(
              text,
              style: TextStyle(
                fontSize: screenWidth * 0.03, // Dimensione del font responsiva
                fontWeight: FontWeight.bold,
                color: Colors.black, // Colore del testo
                fontFamily: 'RetroGaming',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
