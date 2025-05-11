import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../entities/user.dart';

class StreakPage extends StatefulWidget {
  const StreakPage({Key? key}) : super(key: key);

  @override
  _StreakPageState createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  final Map<String, int> _thresholds = {
    '1 Day': 1,
    '3 Days': 3,
    '1 Week': 7,
    '2 Weeks': 14,
    '3 Weeks': 21,
    '1 Month': 30,
    '2 Months': 60,
    '3 Months': 90,
    '6 Months': 180,
    '9 Months': 270,
    '1 Year': 365,
  };

  int? streakDays;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await User.fetchUser();
      setState(() => streakDays = user.streakCount);
    } catch (e) {
      print("Failed to fetch user: $e");
    }
  }

  List<_Achievement> get _achievements => _thresholds.entries.map((e) {
    final unlocked = (streakDays ?? 0) >= e.value;
    final idx = _thresholds.keys.toList().indexOf(e.key) + 1;

    // First 5 use PNGs, others use Lottie
    final iconPath = unlocked
        ? (idx <= 8
        ? 'assets/images/achievements/achv_$idx.png'
        : 'assets/Animations/achvs/achv_$idx.json')
        : null;

    return _Achievement(
      title: e.key,
      unlocked: unlocked,
      iconPath: iconPath,
      isLottie: idx > 8,
    );
  }).toList();

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/images/buttons/back_button.png'),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Achievements',
          style: TextStyle(
            fontFamily: 'RetroGaming',
            color: Color(0xFF000000),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight + 16, left: 16, right: 16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _achievements.length,
          itemBuilder: (context, index) => _AchievementTile(
            achievement: _achievements[index],
          ),
        ),
      ),
    );
  }
}

class _Achievement {
  final String title;
  final bool unlocked;
  final String? iconPath;
  final bool isLottie;

  _Achievement({
    required this.title,
    required this.unlocked,
    this.iconPath,
    required this.isLottie,
  });
}

class _AchievementTile extends StatefulWidget {
  final _Achievement achievement;
  final double iconSize = 330.0;

  const _AchievementTile({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  @override
  __AchievementTileState createState() => __AchievementTileState();
}

class __AchievementTileState extends State<_AchievementTile>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isVisible = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.5;
    if (visible != _isVisible) {
      setState(() => _isVisible = visible);
      _handleAnimationState();
    }
  }

  void _handleAnimationState() {
    if (_isVisible && widget.achievement.unlocked && widget.achievement.isLottie && _isLoaded) {
      _controller
        ..reset()
        ..repeat();
    } else {
      _controller.stop();
    }
  }

  Widget _buildAnimationOrIcon() {
    if (!widget.achievement.unlocked) {
      return Icon(
        Icons.lock,
        size: widget.iconSize * 0.2,
        color: Colors.grey,
      );
    }

    if (widget.achievement.isLottie && _isVisible && widget.achievement.iconPath != null) {
      return FutureBuilder<LottieComposition>(
        future: AssetLottie(widget.achievement.iconPath!).load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            final composition = snapshot.data!;
            _controller.duration = composition.duration;
            _controller.repeat();
            _isLoaded = true;
            return Lottie(
              composition: composition,
              controller: _controller,
              width: widget.iconSize,
              height: widget.iconSize,
              frameRate: FrameRate(15),
            );
          }
          return const SizedBox(); // or CircularProgressIndicator()
        },
      );
    } else if (!widget.achievement.isLottie && widget.achievement.iconPath != null) {
      return Image.asset(
        widget.achievement.iconPath!,
        width: widget.iconSize,
        height: widget.iconSize,
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.achievement.title),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/statistics/stats_box.png',
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
          _buildAnimationOrIcon(),
          Positioned(
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.achievement.title,
                style: const TextStyle(
                  fontFamily: 'RetroGaming',
                  fontSize: 14,
                  color: Color(0xFFE9E6A8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
