import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../entities/user.dart';

class StreakPage extends StatefulWidget {
  const StreakPage({Key? key}) : super(key: key);

  @override
  _StreakPageState createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> with TickerProviderStateMixin {
  //Map title : days required
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


  final double _titleBottomOffset = 2;
  final double _iconSize = 350.0;

  String? userName;
  int? streakDays;
  int? bestScore;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await User.fetchUser();
      setState(() {
        userName = user.nickname;
        streakDays = user.streakCount;
        bestScore = user.higherLowerBestScore;
      });
    } catch (e) {
      print("Failed to fetch user info: $e");
    }
  }

  /// This method returns a list of achievements based on the user's streak days.
  List<_Achievement> get _achievements {
    final days = streakDays ?? 0;
    return _thresholds.entries.map((e) {
      final unlocked = days >= e.value;
      //better way to get paths
      final idx = _thresholds.keys.toList().indexOf(e.key) + 1;
      return _Achievement(
        title: e.key,
        unlocked: unlocked,
        iconPath: unlocked
            ? 'assets/Animations/achvs/achv_$idx.json'
            : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final crossAxisCount = media.width > media.height ? 4 : 2;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/images/buttons/back_button.png'),
          onPressed: () => Navigator.of(context).pop(),
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
        padding: const EdgeInsets.only(
            top: kToolbarHeight + 16, left: 16, right: 16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _achievements.length,
          itemBuilder: (context, index) {
            return _buildAchievementTile(_achievements[index]);
          },
        ),
      ),
    );
  }

  Widget _buildAchievementTile(_Achievement achievement) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // background box
        Image.asset(
          'assets/images/statistics/stats_box.png',
          fit: BoxFit.fill,
          width: double.infinity,
          height: double.infinity,
        ),
        // icona o lucchetto
        if (achievement.unlocked && achievement.iconPath != null)
          Lottie.asset(
            achievement.iconPath!,
            width: _iconSize,
            height: _iconSize,
          )
        else
          Icon(
            Icons.lock,
            size: _iconSize * 0.2,
            color: Colors.grey,
          ),
        // titolo con sfondo nero
        Positioned(
          bottom: _titleBottomOffset,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              achievement.title,
              style: const TextStyle(
                fontFamily: 'RetroGaming',
                fontSize: 14,
                color: Color(0xFFE9E6A8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Achievement {
  final String title;
  final bool unlocked;
  final String? iconPath;

  _Achievement({
    required this.title,
    required this.unlocked,
    this.iconPath,
  });
}
