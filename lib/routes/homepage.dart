import 'package:demo_todo_with_flutter/routes/Game1/higher_or_lower.dart';
import 'package:demo_todo_with_flutter/routes/Learn.dart';
import 'package:demo_todo_with_flutter/routes/Streak.dart';
import 'package:demo_todo_with_flutter/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:demo_todo_with_flutter/routes/LoginPage.dart';
import 'package:lottie/lottie.dart';

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
  bool _isWindowOpen = true; // Stato della finestra (aperta o chiusa)

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
    final plantBottomPosition = groundHeight * 0.28;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  screenWidth * 0.05, // Padding orizzontale proporzionale
              vertical: screenHeight * 0.02, // Padding verticale proporzionale
            ),
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
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up,
                      size: 30),
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
                            'assets/images/background/background3.jpg',
                            fit: BoxFit.cover,
                            width: screenWidth * 2.5,
                            height: screenHeight,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/pixel_animations/ground_pixel.png',
                      fit: BoxFit.fill,
                      height: groundHeight * 0.8,
                      width: screenWidth,
                    ),
                  ),
                  Positioned(
                    bottom: plantBottomPosition,
                    child: GestureDetector(
                      onTap: () {},
                      child: FutureBuilder<LottieComposition>(
                        future: _plantAnimation,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return Lottie(
                                composition: snapshot.data!,
                                width: 400,
                                height: 400);
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.1, // Posiziona la finestra in alto
                    left: _isWindowOpen
                        ? screenWidth * 0.15 // Posizione normale quando aperta
                        : screenWidth -
                            50, // Sposta la finestra quasi fuori dallo schermo
                    right: _isWindowOpen
                        ? screenWidth * 0.15 // Margine destro quando aperta
                        : null, // Rimuovi margine destro quando chiusa
                    child: GestureDetector(
                      onTap: () {
                        if (!_isWindowOpen) {
                          setState(() {
                            _isWindowOpen = true; // Riapre la finestra
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 300), // Animazione fluida
                        height: _isWindowOpen
                            ? screenHeight *
                                0.4 // Altezza normale quando aperta
                            : 150, // Altezza sufficiente per visualizzare la scritta verticale
                        width: _isWindowOpen
                            ? screenWidth *
                                0.7 // Larghezza normale quando aperta
                            : 50, // Larghezza ridotta quando chiusa
                        padding: _isWindowOpen
                            ? const EdgeInsets.all(
                                20) // Padding normale quando aperta
                            : const EdgeInsets.symmetric(
                                vertical:
                                    10), // Padding verticale quando chiusa
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
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Here is the curiosities window.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 40),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _isWindowOpen =
                                              false; // Chiude la finestra
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .zero, // Rimuove i bordi stondati
                                        ),
                                        backgroundColor: const Color(
                                            0xFF18a663), // Colore di sfondo (opzionale)
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical:
                                                10), // Padding (opzionale)
                                      ),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              )
                            : const Center(
                                // Centra la scritta verticalmente e orizzontalmente
                                child: RotatedBox(
                                  quarterTurns:
                                      3, // Ruota il testo di 90° in senso antiorario
                                  child: const Text(
                                    'Curiosities',
                                    style: TextStyle(
                                      fontSize:
                                          20, // Aumenta la dimensione del testo
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                      ),
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
      color: const Color(0xFF18a663),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomMenuButton(Icons.videogame_asset, 'Games', const GamePage()),
          _bottomMenuButton(Icons.add_task, 'Streak', const Streak()),
          _bottomMenuButton(Icons.explore_rounded, 'Learn', const Learn()),
        ],
      ),
    );
  }

  Widget _bottomMenuButton(IconData icon, String label, Widget page) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
