import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../../entities/user.dart';
import '/services/CustomButton.dart';
import 'Alcohol.dart';
import '../../services/auth.dart';
import '../../services/GameService.dart';

Future<List<Alcohol>> loadAlcohols() async {
  final rawData = await rootBundle.loadString('assets/infos/alcohols.txt');
  final lines = LineSplitter.split(rawData).toList();

  return lines.where((line) {
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
  const HigherOrLower({super.key});

  @override
  _HigherOrLowerState createState() => _HigherOrLowerState();
}

class _HigherOrLowerState extends State<HigherOrLower>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final authService = AuthService();
  final _gameService = GameService();
  final Random _random = Random();

  Timer? _questionTimer;
  bool _showQuestionButton = false;
  bool _showQuestionBox = false;
  Map<String, List<String>> _questions = {'true': [], 'false': []};
  String? _selectedQuestion;
  bool? _correctAnswer;
  bool _isDoublePoints = false;
  Timer? _doublePointsTimer;

  List<Alcohol> allAlcohols = [];
  late Alcohol leftAlcohol;
  late Alcohol rightAlcohol;
  User? user;

  bool _isMuted = false;
  bool _isGameOver = false;

  int score = 0;
  int bestScore = 0;

  late AnimationController _upController;
  late AnimationController _downController;
  late Animation<Offset> _upAnimation;
  late Animation<Offset> _downAnimation;

  Future<void> _loadQuestions() async {
    final rawData =
        await rootBundle.loadString('assets/higher_or_lower/questions.txt');
    final lines = LineSplitter.split(rawData).toList();

    String currentCategory = '';
    for (var line in lines) {
      if (line.endsWith(':')) {
        currentCategory = line.replaceAll(':', '').trim().toLowerCase();
      } else if (line.isNotEmpty) {
        _questions[currentCategory] = [
          ..._questions[currentCategory]!,
          line.trim()
        ];
      }
    }
  }

  void _startQuestionTimer() {
    // Cancel existing timer first
    _questionTimer?.cancel();

    _questionTimer = Timer.periodic(
      Duration(seconds: Random().nextInt(20) + 2),
      (_) {
        if (!_isGameOver && !_showQuestionBox) {
          setState(() => _showQuestionButton = true);
          _questionTimer?.cancel();
        }
      },
    );
  }

  void _handleQuestionButton() {
    setState(() {
      _showQuestionButton = false;
      _showQuestionBox = true;
      final rnd = Random();
      final category = rnd.nextBool() ? 'true' : 'false';
      _selectedQuestion =
          _questions[category]![rnd.nextInt(_questions[category]!.length)];
      _correctAnswer = category == 'true';
    });
  }

  void _handleAnswer(bool userAnswer) {
    if (userAnswer == _correctAnswer) {
      setState(() {
        _isDoublePoints = true;
        _doublePointsTimer?.cancel();
        _doublePointsTimer = Timer(const Duration(seconds: 10), () {
          setState(() => _isDoublePoints = false);
        });
      });
    } else {
      setState(() {
        _isGameOver = true;
        user?.addXP(score);
      });
    }
    setState(() {
      _showQuestionBox = false;
      _startQuestionTimer();
    });
  }

  @override
  void initState() {
    _loadUser();

    super.initState();
    _loadQuestions();
    _startQuestionTimer();
    _isMuted = true;

    if (!_isMuted) {
      _playMusic();
    }

    _gameService.getBestScore().then((fetchedBestScore) {
      setState(() {
        bestScore = fetchedBestScore;
      });
    });

    loadAlcohols().then((alcohols) {
      setState(() {
        allAlcohols = alcohols;
        _initializeRound();
      });
    });

    _upController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _downController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _upAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-4, 4), // Upper-left diagonal
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-4, 4),
          end: const Offset(4, -4), // Lower-right diagonal
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(4, -4),
          end: Offset.zero, // Return to center
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_upController);

    _downAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-4, -4), // Lower-left diagonal
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-4, -4),
          end: const Offset(4, 4), // Upper-right diagonal
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(4, 4),
          end: Offset.zero, // Return to center
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_downController);
  }

  Future<void> _loadUser() async {
    try {
      user = await User.fetchUser();
    } catch (e) {
      print("Failed to fetch user info: $e");
    }
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
    print('score: $score, bestScore: $bestScore');

    if (score >= bestScore) {
      bestScore = score;
      print('UPDATING BEST SCORE TO: $bestScore');
      _gameService
          .updateBestScore(bestScore); // Update the best score in the database
    }
    Navigator.pop(context);
  }

  void _initializeRound() {
    if (allAlcohols.isEmpty) return;
    // Cancel any existing timers
    _questionTimer?.cancel();
    _doublePointsTimer?.cancel();

    setState(() {
      leftAlcohol = allAlcohols[_random.nextInt(allAlcohols.length)];
      _updateRound();
      // Reset question button visibility
      _showQuestionButton = false;
      _showQuestionBox = false;
      // Start fresh timer
      _startQuestionTimer();
    });
  }

  void _updateRound() {
    if (allAlcohols.isEmpty) return;
    do {
      rightAlcohol = allAlcohols[_random.nextInt(allAlcohols.length)];
    } while (rightAlcohol.name == leftAlcohol.name);
  }

  void _openQuestionBox() {
    setState(() {
      _showQuestionBox = true;
      _showQuestionButton = false;
      _selectedQuestion = null;
      _correctAnswer = null;
    });
  }

  void _checkGuess(String guess) {
    if (_showQuestionBox) return; //Prevent guesses while question is shown

    bool isRightHigher = rightAlcohol.abv > leftAlcohol.abv;
    bool isGuessCorrect = (guess == "up" && isRightHigher) ||
        (guess == "down" && !isRightHigher) ||
        (rightAlcohol.abv == leftAlcohol.abv);

    setState(() {
      if (isGuessCorrect) {
        score += _isDoublePoints ? 2 : 1;
        if (score > bestScore) bestScore = score;
        leftAlcohol = rightAlcohol;
        _updateRound();
      } else {
        user?.addXP(score);
        _isGameOver = true;
      }
    });
  }

  void _playAgain() {
    setState(() {
      _isGameOver = false;
      score = 0;
      // Reset timer-related states
      _questionTimer?.cancel();
      _doublePointsTimer?.cancel();
      _showQuestionButton = false;
      _showQuestionBox = false;
      _isDoublePoints = false;
      // Reinitialize game
      _initializeRound();
    });
  }

  @override
  void dispose() {
    _upController.dispose();
    _downController.dispose();
    _audioPlayer.dispose();
    _questionTimer?.cancel();
    _doublePointsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final isPortrait = media.orientation == Orientation.portrait;

    if (allAlcohols.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    //PORTRAIT
    if (isPortrait) {
      return Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SizedBox.expand(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildBackground(screenWidth, screenHeight, true),
                        _buildAlcoholDisplays(screenWidth * 0.8, screenHeight),
                        _buildTopBar(),
                        if (!_isGameOver && !_showQuestionBox) ...[
                          _buildGameButton(
                            bottom: screenHeight * 0.15,
                            right: screenWidth * 0.08,
                            text: "↑",
                            onPressed: () {
                              _checkGuess("up");
                              _upController.forward(from: 0.0);
                            },
                            animation: _upAnimation,
                          ),
                          _buildGameButton(
                            bottom: screenHeight * 0.15,
                            right: screenWidth * 0.3,
                            text: "↓",
                            onPressed: () {
                              _downController.forward(from: 0.0);
                              _checkGuess("down");
                            },
                            animation: _downAnimation,
                          ),
                        ],
                        if (_showQuestionButton &&
                            !_isGameOver &&
                            !_showQuestionBox)
                          _buildQuestionButton(
                            text: "2x",
                            onPressed: _handleQuestionButton,
                          ),
                        if (_showQuestionBox)
                          _buildQuestionBox(screenWidth * 3, screenHeight),
                        Positioned(
                          top: screenHeight * 0.095,
                          child: Text(
                            "Score: $score\nBest: $bestScore",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenHeight * 0.02,
                              fontFamily: 'RetroGaming',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          top: screenHeight * 0.15,
                          child: AnimatedOpacity(
                            opacity: _isDoublePoints ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: const Text(
                              '2X POINTS!',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.yellow,
                                fontFamily: 'RetroGaming',
                                //color in hex
                                backgroundColor: Color(0xFF5460C1),
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.yellow,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isGameOver) _buildGameOverBox(screenWidth * 3, screenHeight),
          ],
        ),
      );
    }

    //NOT PORTRAIT
    else {
      return Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SizedBox.expand(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildBackground(screenWidth, screenHeight, false),
                        _buildAlcoholDisplays(screenWidth * 0.8, screenHeight),
                        _buildTopBar(),
                        if (!_isGameOver && !_showQuestionBox) ...[
                          _buildGameButton(
                            bottom: screenHeight * 0.5,
                            right: screenWidth * 0.05,
                            text: "↑",
                            onPressed: () {
                              _checkGuess("up");
                              _upController.forward(from: 0.0);
                            },
                            animation: _upAnimation,
                          ),
                          _buildGameButton(
                            bottom: screenHeight * 0.39,
                            right: screenWidth * 0.05,
                            text: "↓",
                            onPressed: () {
                              _checkGuess("down");
                              _downController.forward(from: 0.0);
                            },
                            animation: _downAnimation,
                          ),
                        ],
                        if (_showQuestionButton &&
                            !_isGameOver &&
                            !_showQuestionBox)
                          _buildQuestionButton(
                            text: "2x",
                            onPressed: _handleQuestionButton,
                          ),
                        if (_showQuestionBox)
                          _buildQuestionBox(screenWidth, screenHeight),
                        Positioned(
                          top: screenHeight * 0.133,
                          child: Text(
                            "Score: $score\nBest: $bestScore",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenHeight * 0.025,
                              fontFamily: 'RetroGaming',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          top: screenHeight * 0.2,
                          child: AnimatedOpacity(
                            opacity: _isDoublePoints ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: const Text(
                              '2X POINTS!',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.yellow,
                                fontFamily: 'RetroGaming',
                                //color in hex
                                backgroundColor: Color(0xFF5460C1),
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.yellow,
                                  ),
                                ],
                              ),
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
  }

  Widget _buildGameOverBox(double screenWidth, double screenHeight) {
    /*final streakService = StreakService();
    streakService.incrementStreak();*/

    print('score: $score, bestScore: $bestScore');
    if (score >= bestScore) {
      bestScore = score;
      print('UPDATING BEST SCORE TO: $bestScore');
      _gameService
          .updateBestScore(bestScore); // Update the best score in the database
    }

    return Center(
      child: Container(
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
            SizedBox(height: screenHeight * 0.06),
            Text(
              "Score: $score\nBest: $bestScore",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenHeight * 0.02,
                fontFamily: 'RetroGaming',
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            GestureDetector(
              onTap: _playAgain,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  "PLAY AGAIN",
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    fontFamily: 'RetroGaming',
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            GestureDetector(
              onTap: _goBackToHomePage,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  "RETURN TO HOME",
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    fontFamily: 'RetroGaming',
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      bottom: screenHeight / 2 - 20,
      width: 120,
      child: CustomButton(
        text: text,
        imagePath: 'assets/images/buttons/question_button.png',
        onPressed: onPressed,
        textAlignment: Alignment.center,
        textStyle: TextStyle(
          fontSize: screenHeight * 0.03,
          color: const Color(0xFFE9E6A8),
          fontFamily: 'RetroGaming',
          fontWeight: FontWeight.bold,
        ),
        textPadding: EdgeInsets.only(bottom: screenHeight * 0.006),
      ),
    );
  }

  Widget _buildQuestionBox(double screenWidth, double screenHeight) {
    if (!_showQuestionBox) return const SizedBox.shrink();

    return Center(
      child: Container(
        width: screenWidth * 0.3,
        height: screenHeight * 0.3,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/higher_or_lower/question_box.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.08),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: Text(
                _selectedQuestion ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight * 0.018,
                  fontFamily: 'RetroGaming',
                  color: const Color(0xFFE9E6A8),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _handleAnswer(false),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      "FALSE",
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                        fontFamily: 'RetroGaming',
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _handleAnswer(true),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      "TRUE",
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                        fontFamily: 'RetroGaming',
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton({
    double? left,
    double? right,
    required double bottom,
    required String text,
    required VoidCallback onPressed,
    required Animation<Offset> animation,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned(
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.translate(
            offset: animation.value,
            child: child,
          );
        },
        child: CustomButton(
          text: text,
          imagePath: 'assets/images/buttons/games_button.png',
          onPressed: onPressed,
          textAlignment: Alignment.center,
          textStyle: TextStyle(
            fontSize: screenHeight * 0.05,
            color: const Color(0xFFE9E6A8),
            fontFamily: 'RetroGaming',
            fontWeight: FontWeight.bold,
          ),
          textPadding: EdgeInsets.only(bottom: screenHeight * 0.02),
        ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Image.asset(alcohol.imagePath,
            width: screenWidth * 0.2, height: screenHeight * 0.35),
        const SizedBox(height: 8),
        Text(
          alcohol.name,
          style: TextStyle(
            fontSize: screenHeight * 0.025,
            fontFamily: 'RetroGaming',
            color: Colors.white,
          ),
        ),
        Text(
          hideAbv ? "???" : "${alcohol.abv.toStringAsFixed(1)}%",
          style: TextStyle(
            fontSize: screenHeight * 0.02,
            fontFamily: 'RetroGaming',
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(double screenWidth, double screenHeight, bool isPortrait) {

    if (isPortrait) {
      return Positioned.fill(
        child: Image.asset(
          'assets/higher_or_lower/higherorlower_vertical.png',
          fit: BoxFit.fill,
          width: screenWidth,
          height: screenHeight,
        ),
      );
    }

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: screenHeight * 0.06,
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
                hoverColor: Colors.transparent,
                icon: Image.asset(
                  'assets/images/buttons/back_button.png',
                  width: screenWidth * 0.1,
                  height: screenHeight * 0.1,
                ),
                //add xp and go back to homepage
                onPressed: () {
                  user?.addXP(score);
                  _goBackToHomePage();
                },
                tooltip: "Back to Home",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
