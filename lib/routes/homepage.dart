import 'package:demo_todo_with_flutter/routes/Game/higher_or_lower.dart';
import 'package:demo_todo_with_flutter/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
  bool _isCuriositiesWidgetVisible = false; // Stato del widget delle curiosità

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
    //await authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HigherOrLower(username: widget.username ?? '')),
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
                  // Bottone "GAMES"
                  _buildHomeButton(
                    text: 'GAMES',
                    left: screenWidth * 0.05,
                    right: null,
                    bottom: groundHeight * 0.02,
                    onPressed: _games,
                  ),
                  // Bottone "STREAK"
                  _buildHomeButton(
                    text: 'STREAK',
                    left: null,
                    right: null,
                    bottom: groundHeight * 0.02,
                    onPressed: () {
                      // Azione per il bottone STREAK
                      print("Naviga a STREAK");
                    },
                  ),
                  // Bottone "ACCOUNT"
                  _buildHomeButton(
                    text: 'ACCOUNT',
                    left: null,
                    right: screenWidth * 0.05,
                    bottom: groundHeight * 0.02,
                    onPressed: () {
                      // Azione per il bottone ACCOUNT
                      print("Naviga a ACCOUNT");
                    },
                  ),
                  _buildRectangle(screenWidth, screenHeight),
                  _buildCuriositiesWidget(
                    text: 'Curiosities',
                    imagePath: 'assets/images/curiosities/CuriosityText.png',
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
              opacity: 1, // Set the desired opacity value (0.0 to 1.0)
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

// Function for the ground
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

// Function for the plant
  Widget _buildPlant(double plantBottomPosition) {
    return Positioned(
      bottom: plantBottomPosition,
      child: GestureDetector(
        onTap: () {},
        child: FutureBuilder<LottieComposition>(
          future: _plantAnimation,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Lottie(
                  composition: snapshot.data!, width: 350, height: 350);
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget _buildHomeButton({
    required String text,
    double? left, // make nullable
    double? right, // make nullable
    required double bottom,
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
        textAlignment: Alignment.bottomRight,
        textPadding: const EdgeInsets.only(bottom: 10),
        fontFamily: 'RetroGaming',
      ),
    );
  }

// Function for the "Curiosities" window
  Widget _buildCuriositiesWindow(double screenWidth, double screenHeight) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300), // Aggiunta animazione
      top: screenHeight * 0.1, // Posizionata più in alto (10% dall'alto)
      left: _isWindowOpen
          ? screenWidth * 0.2
          : -screenWidth, // Scorre da sinistra verso destra
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isWindowOpen = false; // Chiudi la finestra quando cliccata
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: screenHeight * 0.4, // Altezza ridotta (40% dello schermo)
          width: screenWidth * 0.6, // Larghezza ridotta (60% dello schermo)
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Immagine di sfondo
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Angoli arrotondati
                child: Image.asset(
                  'assets/images/curiosities/CuriosityText.png', // Percorso dell'immagine
                  fit: BoxFit.cover, // Adatta l'immagine all'area disponibile
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // Testo sovrapposto
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Curiosity',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Testo nero
                        fontFamily: 'RetroGaming',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Here is the curiosities window with an image background.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Testo nero
                        fontFamily: 'RetroGaming',
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isWindowOpen = false; // Chiudi la finestra
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        backgroundColor: const Color(0xFF18a663),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildRectangle(double screenWidth, double screenHeight) {
    return Positioned(
      top: screenHeight / 3 - 85, // Posizione verticale invariata
      left: 10, // Vicino al bordo sinistro
      child: MouseRegion(
        cursor: SystemMouseCursors.click, // Cambia il cursore in una manina
        child: GestureDetector(
          onTap: () {
            // Mostra il widget delle curiosità
            setState(() {
              _isCuriositiesWidgetVisible = true;
            });
          },
          child: Container(
            width:
                screenWidth * 0.35, // Larghezza aumentata (quasi metà pagina)
            height: screenHeight * 0.5, // Altezza invariata
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0), // Colore trasparente
              borderRadius: BorderRadius.circular(10), // Angoli arrotondati
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
      return const SizedBox.shrink(); // Nascondi il widget se non visibile
    }

    return Stack(
      children: [
        // Rileva clic al di fuori del widget
        GestureDetector(
          onTap: () {
            setState(() {
              _isCuriositiesWidgetVisible = false; // Nascondi il widget
            });
          },
          child: Container(
            color: Colors.transparent, // Sfondo trasparente per rilevare i clic
            width: screenWidth,
            height: screenHeight,
          ),
        ),
        // Widget delle curiosità
        Positioned(
          top: screenHeight * 0.02, // Posizionato più in alto
          left: screenWidth * 0.2, // Posizionato al centro orizzontale
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              // Immagine di sfondo
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Angoli arrotondati
                child: Image.asset(
                  imagePath, // Percorso dell'immagine
                  fit: BoxFit.fill, // Mostra l'intera immagine senza tagliarla
                  width: screenWidth * 0.6, // Larghezza del widget
                  height: screenHeight * 0.5, // Altezza del widget
                ),
              ),
              // Testo "Curiosities" in alto a sinistra
              Positioned(
                top: screenHeight * 0.04,
                left: screenWidth * 0.1,
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Colore del testo nero
                    fontFamily: 'RetroGaming',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
