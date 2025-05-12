import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../entities/user.dart';
import '../services/GameService.dart';
import '../services/Streak.dart';
import '../services/auth.dart';
import 'Game/higher_or_lower.dart';
import 'LoginPage.dart';
import 'StreakPage.dart';
import 'Learn.dart';
import '/services/CustomButton.dart';
import 'account_page.dart';

import 'package:demo_todo_with_flutter/services/localeProvider.dart';
import 'package:provider/provider.dart';

// localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final authService = AuthService();
  final streak = StreakService();
  final _gameService = GameService();
  final StreakService streakService = StreakService();

  late AnimationController _cloudAnimationController;
  late Future<LottieComposition> _plantAnimation;
  bool _isMuted = false;
  bool _isCuriositiesWidgetVisible = false;
  String? _randomCuriosity;

  // USER DATA
  User? user;
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

  late Map<int, Future<LottieComposition>> _animationsByMilestone;

  @override
  void initState() {
    super.initState();
    _loadUser();

    _animationsByMilestone = {
      50: AssetLottie('assets/Animations/plant_lv2.json').load(),
      100: AssetLottie('assets/Animations/plant_lv3.json').load(),
      250: AssetLottie('assets/Animations/plant_lv4.json').load(),
    };

    _cloudAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 600),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: false);

    if (!_isMuted) {
      _playMusic();
    }
  }

  Future<LottieComposition> _loadLottieAnimation(int currentXP) {
    int? milestone = _animationsByMilestone.keys
        .where((key) => currentXP >= key)
        .fold<int?>(null,
            (prev, element) => prev == null || element > prev ? element : prev);

    return milestone != null
        ? _animationsByMilestone[milestone]!
        : AssetLottie('assets/Animations/plant_lv1.json').load();
  }

  Widget _buildPlant(double bottomPos, double plantSize) {
    final w = MediaQuery.of(context).size.width * 0.8;
    final h = MediaQuery.of(context).size.height * 0.8;
    final faceAsset = _faceMap[_faceMood]!;
    final animation = user != null
        ? _loadLottieAnimation(user!.getXP())
        : AssetLottie('assets/Animations/plant_lv1.json').load();

    return Positioned(
      bottom: bottomPos,
      child: SizedBox(
        width: plantSize,
        height: plantSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder<LottieComposition>(
              future: animation,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.done &&
                    snap.hasData) {
                  return Lottie(
                      composition: snap.data!,
                      width: plantSize,
                      height: plantSize);
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

  Future<void> _loadUser() async {
    try {
      user = await User.fetchUser();
      setState(() {
        userName = user?.nickname;
        streakDays = user?.streakCount;
        bestScore = user?.higherLowerBestScore;
      });
    } catch (e) {
      print("Failed to fetch user info: $e");
    }
  }

  void _playMusic() async {
    try {
      //await _audioPlayer.setAsset('assets/audio/homepage_music.ogg');
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
        builder: (context) => const HigherOrLower(),
      ),
    ).then((_) {
      _loadUser();
    });
  }

  Future<void> _loadRandomCuriosity() async {
    final String fileContent = await rootBundle.loadString(
        'assets/infos/' + AppLocalizations.of(context)!.homePage_curiosityFile);
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

    final localeProvider = Provider.of<LocaleProvider>(context);

    // scale based on orientation: base landscape width 1920, portrait height 1080
    final scaleFactor =
        isPortrait ? (screenHeight / 1080) : (screenWidth / 1920);

    double fontSize(double base) => base * scaleFactor;

    final groundHeight = screenHeight * 0.5;
    final plantBottomPosition = groundHeight * 0.18;

    //PORTRAIT
    if (isPortrait) {
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
                    _buildPlant(plantBottomPosition, screenWidth * 0.6),
                    _buildLogOutButton(
                        onPressed: _logout,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight),
                    _buildHomeButton(
                        text: AppLocalizations.of(context)!.homePage_play,
                        left: screenWidth * 0.05,
                        bottom: groundHeight * 0.02,
                        onPressed: _games,
                        scaleFactor: scaleFactor * 0.7),
                    _buildHomeButton(
                        text: AppLocalizations.of(context)!.homePage_streak,
                        bottom: groundHeight * 0.02,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StreakPage()),
                          ).then((_) => _loadUser());
                        },
                        scaleFactor: scaleFactor * 0.7),
                    _buildHomeButton(
                      text: AppLocalizations.of(context)!.homePage_account,
                      right: screenWidth * 0.05,
                      bottom: groundHeight * 0.02,
                      onPressed: () async {
                        // Naviga verso la pagina dell'account e aspetta il risultato
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AccountPage()),
                        );

                        // Se il risultato è `true`, ricarica i dati della homepage
                        if (result == true) {
                          _loadUser(); // Ricarica i dati dell'utente
                        }
                      },
                      scaleFactor: scaleFactor * 0.7,
                    ),
                    _buildRectangle(screenWidth, screenHeight, onTap: () async {
                      await _loadRandomCuriosity();
                      setState(() => _isCuriositiesWidgetVisible = true);
                    }),
                    _buildCuriositiesWidget(isVisible: _isCuriositiesWidgetVisible, screenWidth: screenWidth * 1.5, screenHeight: screenHeight * 0.5, curiosity: _randomCuriosity, top: groundHeight * 0.4, left: screenWidth * 0.07, fontSize: 10),
                    _buildInfoRectangle(screenWidth: screenWidth * 3, screenHeight: screenHeight * 0.5, scaleFactor: scaleFactor * 0.8, top: screenHeight * 0.2, left: screenWidth * 0.2),

                    //INTERNATIONALIZATION
                    _buildHomeButton(
                      text: 'en/it',
                      right: screenWidth * 0.05,
                      bottom: groundHeight * 1.82,
                      onPressed: localeProvider.toggleLocale,
                      scaleFactor: scaleFactor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    //NOT PORTRAIT
    else {
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
                    _buildPlant(plantBottomPosition, screenHeight * 0.6),
                    _buildLogOutButton(
                        onPressed: _logout,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight),
                    _buildHomeButton(
                        text: AppLocalizations.of(context)!.homePage_play,
                        left: screenWidth * 0.05,
                        bottom: groundHeight * 0.02,
                        onPressed: _games,
                        scaleFactor: scaleFactor),
                    _buildHomeButton(
                        text: AppLocalizations.of(context)!.homePage_streak,
                        bottom: groundHeight * 0.02,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StreakPage()),
                          ).then((_) => _loadUser());
                        },
                        scaleFactor: scaleFactor),
                    _buildHomeButton(
                      text: AppLocalizations.of(context)!.homePage_account,
                      right: screenWidth * 0.05,
                      bottom: groundHeight * 0.02,
                      onPressed: () async {
                        // Naviga verso la pagina dell'account e aspetta il risultato
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AccountPage()),
                        );

                        // Se il risultato è `true`, ricarica i dati della homepage
                        if (result == true) {
                          _loadUser(); // Ricarica i dati dell'utente
                        }
                      },
                      scaleFactor: scaleFactor,
                    ),
                    _buildRectangle(screenWidth, screenHeight, onTap: () async {
                      await _loadRandomCuriosity();
                      setState(() => _isCuriositiesWidgetVisible = true);
                    }),
                    _buildCuriositiesWidget(isVisible: _isCuriositiesWidgetVisible, screenWidth: screenWidth * 1.3, screenHeight: screenHeight, curiosity: _randomCuriosity, top: groundHeight*0.2, left: screenWidth * 0.12, fontSize: 30),
                    !_isCuriositiesWidgetVisible?
                    _buildInfoRectangle(screenWidth: screenWidth, screenHeight: screenHeight, scaleFactor: scaleFactor, top: screenHeight * 0.1, left: screenWidth * 0.75): const SizedBox.shrink(),

                    //INTERNATIONALIZATION
                    _buildHomeButton(
                      text: 'en/it',
                      right: screenWidth * 0.05,
                      bottom: groundHeight * 1.82,
                      onPressed: localeProvider.toggleLocale,
                      scaleFactor: scaleFactor,
                    ),


                    //REMOVE THE NEXT TWO BUTTONS AFTER DEBUGGING STREAK LOGIC
                    /*_buildHomeButton(
                      text: 'Reset streak',
                      right: screenWidth * 0.04,
                      bottom: groundHeight * 0.75,
                      onPressed: () async {
                        await streakService.resetStreak();
                        await _loadUser();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Streak reset')));
                      },
                      scaleFactor: scaleFactor,
                    ),
                    _buildHomeButton(
                      text: 'Streak++',
                      right: screenWidth * 0.17,
                      bottom: groundHeight * 0.75,
                      onPressed: () async {
                        await user?.incrementStreakDebug();
                        await _loadUser();
                      },
                      scaleFactor: scaleFactor,

                    ),*/



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

  Widget _buildSlider(double width, {required double scaleFactor}) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.homePage_mood,
              style: TextStyle(
                  fontSize: 20 * scaleFactor, fontFamily: 'RetroGaming')),
          Slider(
            activeColor: const Color(0xFFDCAB00),
            inactiveColor: const Color(0xFF8C5261),
            value: _faceMood,
            min: 0,
            max: 1,
            divisions: 2,
            label: _faceMood == 0
                ? AppLocalizations.of(context)!.homePage_sad
                : _faceMood == 0.5
                    ? AppLocalizations.of(context)!.homePage_neutral
                    : AppLocalizations.of(context)!.homePage_happy,
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
        child: CustomButton(
          text: text,
          imagePath: 'assets/images/buttons/games_button.png',
          onPressed: onPressed,
          textAlignment: Alignment.center,
          textPadding: EdgeInsets.only(bottom: h * 0.006),
          textStyle: TextStyle(
            fontSize: 26 * scaleFactor,
            color: const Color(0xFFE9E6A8),
            fontFamily: 'RetroGaming',
            //fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLogOutButton(
      {required VoidCallback onPressed,
      required double screenWidth,
      required double screenHeight}) {
    return Positioned(
      top: 0.02 * screenHeight,
      left: 0.027 * screenWidth,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: Image.asset('assets/images/buttons/logout_button.png',
              width: screenWidth * 0.1, height: screenHeight * 0.1),
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
          child: GestureDetector(
              onTap: onTap,
              child: Container(
                  width: w * 0.35,
                  height: h * 0.5,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10)))),
        ));
  }

  Widget _buildCuriositiesWidget({
    required fontSize,
    required double top,
    required double screenWidth,
    required double screenHeight,
    required bool isVisible,
    String? curiosity,
    required double left,
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
          left: left - 7,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/images/curiosities/CuriosityBox_v2.png",
                  fit: BoxFit.fill,
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.4,
                ),
              ),
              SizedBox(
                width: screenWidth * 0.6,
                height: screenHeight * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * 0.12, right: screenWidth * 0.04),
                      child: Text(
                        AppLocalizations.of(context)!.homePage_curiosityHeader,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'RetroGaming',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * 0.12, right: screenWidth * 0.04),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRectangle({
    required double screenWidth,
    required double screenHeight,
    required double scaleFactor,
    required double top,
    required double left,
  }) {
    final boxW = screenWidth * 0.20;
    final boxH = screenHeight * 0.4;
    return Positioned(
      top: top,
      left: left,
      child: SizedBox(
        width: boxW,
        height: boxH,
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/statistics/stats_box.png',
                    fit: BoxFit.fill, width: boxW, height: boxH)),
            Positioned(
              top: boxH * 0.05,
              left: boxW * 0.05,
              child: Text(
                user?.nickname ?? 'Guest',
                style: TextStyle(
                  fontSize: 25 * scaleFactor,
                  fontFamily: 'RetroGaming',
                  color: const Color(0xFF1C1C1C),
                ),
              ),
            ),
            Positioned(
              top: boxH * 0.2,
              left: boxW * 0.05,
              right: boxW * 0.05,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20 * scaleFactor,
                    fontFamily: 'RetroGaming',
                    color: const Color(0xFF000000),
                  ),
                  children: [
                    TextSpan(
                      text: 'XP: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20 * scaleFactor),
                    ),
                    TextSpan(
                        text: '${user?.getXP()} ' +
                            AppLocalizations.of(context)!.homePage_xpPoints +
                            '\n'),
                    TextSpan(
                      text:
                          AppLocalizations.of(context)!.homePage_personalStreak,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20 * scaleFactor),
                    ),
                    TextSpan(text: '${user?.streakCount} days\n'),
                    TextSpan(
                      text: AppLocalizations.of(context)!
                          .homePage_bestScoreHigherLower,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20 * scaleFactor),
                    ),
                    TextSpan(text: '${user?.higherLowerBestScore}'),
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: boxH * 0.05,
                left: boxW * 0.05,
                right: boxW * 0.05,
                child: _buildSlider(boxW * 0.9, scaleFactor: scaleFactor)),
          ],
        ),
      ),
    );
  }
}


/*class PortraitHome extends StatelessWidget {
  const PortraitHome({super.key});

  @override
  Widget build(BuildContext context) {

  }
}


class LandscapeHome extends StatelessWidget {
  const LandscapeHome({super.key});

  @override
  Widget build(BuildContext context) {

  }
}*/

