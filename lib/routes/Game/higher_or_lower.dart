import 'dart:convert';
import 'dart:math';
import 'package:demo_todo_with_flutter/routes/Game/higher_or_lower.dart';
import 'package:demo_todo_with_flutter/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:demo_todo_with_flutter/routes/LoginPage.dart';
import 'package:lottie/lottie.dart';
import '../Homepage.dart';
import '/services/CustomButton.dart';
import 'Alcohol.dart';

//loads the CSV-formatted alcohol data from the alcohols.txt info file and returns a List<Alcohol>.
Future<List<Alcohol>> loadAlcohols() async {
  final rawData = await rootBundle.loadString('assets/infos/alcohols.txt');
  final lines = LineSplitter.split(rawData).toList();

  //convert valid lines into Alcohol objects
  return lines
      .where((line) {
    final parts = line.split(',').map((part) => part.trim()).toList();
    return parts.length == 3 &&
        parts[0].isNotEmpty &&
        parts[1].isNotEmpty &&
        parts[2].isNotEmpty;
  }).map((line) {
    final parts = line.split(',').map((part) => part.trim()).toList();
    return Alcohol(
      name: parts[0],
      abv: double.parse(parts[1]),
      imagePath: parts[2],
    );
  }).toList();
}

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

  bool _isMuted = false;
  bool _isWindowOpen = false;

  //Game state
  final Random _random = Random();
  List<Alcohol> allAlcohols = [];
  late Alcohol leftAlcohol;
  late Alcohol rightAlcohol;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _isMuted = true;

    if (!_isMuted) {
      _playMusic();
    }

    //Load alcohol data and then initialize the first round
    loadAlcohols().then((alcohols) {
      setState(() {
        allAlcohols = alcohols;
        _initializeRound();
      });
    });
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

  //Initialize the first round by choosing a left alcohol and then a different right alcohol
  void _initializeRound() {
    if (allAlcohols.isEmpty) return;
    leftAlcohol = allAlcohols[_random.nextInt(allAlcohols.length)];
    _updateRound();
  }

  //update the round: pick a new right alcohol that differs from the current left alcohol
  void _updateRound() {
    if (allAlcohols.isEmpty) return;
    do {
      rightAlcohol = allAlcohols[_random.nextInt(allAlcohols.length)];
    } while (rightAlcohol.name == leftAlcohol.name);
  }

  //compare the ABV of the two alcohols based on the player's guess.
  void _checkGuess(String guess) {
    bool isRightHigher = rightAlcohol.abv > leftAlcohol.abv;
    bool isGuessCorrect =
        (guess == "up" && isRightHigher) || (guess == "down" && !isRightHigher) || (rightAlcohol.abv == leftAlcohol.abv);

    setState(() {
      if (isGuessCorrect) {
        score++;
      } else {
        score--;
      }
      //OUTPUT DEBUT (TO REMOVE)
      print("Guess: $guess | Left ABV: ${leftAlcohol.abv}, Right ABV: ${rightAlcohol.abv} | Score: $score");

      //shift the right alcohol to the left
      leftAlcohol = rightAlcohol;
      //pick a new right alcohol.
      _updateRound();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;
    final groundHeight = screenHeight * 0.5;

    //show a loading indicator until the alcohol data has loaded.
    if (allAlcohols.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildBackground(screenWidth, screenHeight),
                  _buildAlcoholDisplays(screenWidth, screenHeight),
                  _buildGameButton(
                    bottom: groundHeight * 0.95,
                    right: screenWidth * 0.05,
                    text: "↑",
                    onPressed: () => _checkGuess("up"),
                  ),
                  _buildGameButton(
                    bottom: groundHeight * 0.75,
                    right: screenWidth * 0.05,
                    text: "↓",
                    onPressed: () => _checkGuess("down"),
                  ),
                  Positioned(
                    top: screenHeight * 0.02,
                    child: Text(
                      "Score: $score",
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'RetroGaming',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------- Widget Builders -------------------------

  ///builds a custom game button (used for up and down buttons in our case)
  Widget _buildGameButton({
    double? left,
    double? right,
    required double bottom,
    required String text,
    required VoidCallback onPressed,

  }) {
    return Positioned(
      bottom: bottom,
      left: left,
      right: right,


      child: CustomButton(
        text: text,
        imagePath: 'assets/images/buttons/games_button.png',


        onPressed: onPressed,
        textAlignment: Alignment.center,
        textStyle: const TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontFamily: 'RetroGaming',
          fontWeight: FontWeight.bold,
        ),
        textPadding: const EdgeInsets.only(bottom: 23),

      ),
    );
  }

  /// Displays the current pair of alcohol objects.
  Widget _buildAlcoholDisplays(double screenWidth, double screenHeight) {
    return Positioned(
      top: screenHeight * 0.3,
      left: screenWidth * 0.2,
      right: screenWidth * 0.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAlcoholDisplay(leftAlcohol),
          _buildAlcoholDisplay(rightAlcohol, hideAbv: true), // Hide ABV for right one
        ],
      ),
    );
  }


  /// Displays an individual alcohol's image, name, and ABV.
  Widget _buildAlcoholDisplay(Alcohol alcohol, {bool hideAbv = false}) {
    return Column(
      children: [
        Image.asset(alcohol.imagePath, width: 200, height: 200),
        const SizedBox(height: 8),
        Text(
          alcohol.name,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'RetroGaming',
            color: Colors.white,
          ),
        ),
        Text(
          hideAbv ? "???" : "${alcohol.abv.toStringAsFixed(1)}%",
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'RetroGaming',
            color: Colors.white70,
          ),
        ),
      ],
    );
  }


  /// Builds the game background.
  Widget _buildBackground(double screenWidth, double screenHeight) {
    return Positioned.fill(
      child: Image.asset(
        'assets/higher_or_lower/higher_or_lower_back.png',
        fit: BoxFit.fill,
        width: screenWidth,
        height: screenHeight,
      ),
    );
  }

  /// Builds the top bar with logout and mute buttons.
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
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              size: 30,
            ),
            onPressed: _toggleMute,
          ),
        ],
      ),
    );
  }
}
