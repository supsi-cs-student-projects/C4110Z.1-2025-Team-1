import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../Homepage.dart';
import '/services/CustomButton.dart';
import 'Alcohol.dart';
import '../../services/auth.dart';

Future<List<Alcohol>> loadAlcohols() async {
  final rawData = await rootBundle.loadString('assets/infos/alcohols.txt');
  final lines = LineSplitter.split(rawData).toList();

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

class _HigherOrLowerState extends State<HigherOrLower> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final authService = AuthService();
  final Random _random = Random();

  List<Alcohol> allAlcohols = [];
  late Alcohol leftAlcohol;
  late Alcohol rightAlcohol;

  bool _isMuted = false;
  bool _isGameOver = false;

  int score = 0;
  int bestScore = 0;

  @override
  void initState() {
    super.initState();
    _isMuted = true;

    if (!_isMuted) {
      _playMusic();
    }

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

  void _goBackToHomePage() {
    Navigator.pop(context);
  }

  void _initializeRound() {
    if (allAlcohols.isEmpty) return;
    leftAlcohol = allAlcohols[_random.nextInt(allAlcohols.length)];
    _updateRound();
  }

  void _updateRound() {
    if (allAlcohols.isEmpty) return;
    do {
      rightAlcohol = allAlcohols[_random.nextInt(allAlcohols.length)];
    } while (rightAlcohol.name == leftAlcohol.name);
  }

  void _checkGuess(String guess) {
    bool isRightHigher = rightAlcohol.abv > leftAlcohol.abv;
    bool isGuessCorrect =
        (guess == "up" && isRightHigher) || (guess == "down" && !isRightHigher);

    setState(() {
      if (isGuessCorrect) {
        score++;
        if (score > bestScore) bestScore = score;
        leftAlcohol = rightAlcohol;
        _updateRound();
      } else {
        _isGameOver = true;
      }
    });
  }

  void _playAgain() {
    setState(() {
      _isGameOver = false;
      score = 0;
      _initializeRound();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final groundHeight = screenHeight * 0.5;

    if (allAlcohols.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SizedBox.expand(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildBackground(screenWidth, screenHeight),
                      _buildAlcoholDisplays(screenWidth, screenHeight),
                      if (!_isGameOver) ...[
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
                      ],
                      Positioned(
                        top: screenHeight * 0.02,
                        child: Text(
                          "Score: $score\nBest: $bestScore",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontFamily: 'RetroGaming',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.26,
                        left: screenWidth * 0.083,
                        child: Text(
                          "Leaderboard",
                          style: const TextStyle(
                            fontSize: 22,
                            fontFamily: 'RetroGaming',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isGameOver) _buildGameOverBox(screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildGameOverBox(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.3,
      height: screenHeight * 0.3,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/higher_or_lower/game_over_box.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Text(
            "Score: $score\nBest: $bestScore",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'RetroGaming',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _playAgain,
            child: const MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                "PLAY AGAIN",
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'RetroGaming',
                  color: Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _goBackToHomePage,
            child: const MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                "RETURN TO HOME",
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'RetroGaming',
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildAlcoholDisplays(double screenWidth, double screenHeight) {
    return Positioned(
      top: screenHeight * 0.3,
      left: screenWidth * 0.2,
      right: screenWidth * 0.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAlcoholDisplay(leftAlcohol),
          _buildAlcoholDisplay(rightAlcohol, hideAbv: true),
        ],
      ),
    );
  }

  Widget _buildAlcoholDisplay(Alcohol alcohol, {bool hideAbv = false}) {
    return Column(
      children: [
        Image.asset(alcohol.imagePath, width: 300, height: 300),
        const SizedBox(height: 8),
        Text(
          alcohol.name,
          style: const TextStyle(
            fontSize: 35,
            fontFamily: 'RetroGaming',
            color: Colors.white,
          ),
        ),
        Text(
          hideAbv ? "???" : "${alcohol.abv.toStringAsFixed(1)}%",
          style: const TextStyle(
            fontSize: 25,
            fontFamily: 'RetroGaming',
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 30),
            onPressed: _goBackToHomePage,
            tooltip: "Back to Home",
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
