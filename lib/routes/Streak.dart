import 'package:flutter/material.dart';

class StreakPage extends StatefulWidget {
  const StreakPage({Key? key}) : super(key: key);

  @override
  _StreakPageState createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> with TickerProviderStateMixin {

  final List<_Achievement> _achievements = [
    _Achievement(title: '1 Day', unlocked: true, iconPath: 'assets/images/achievements/achv_1.png'),
    _Achievement(title: '3 Days', unlocked: false, iconPath: null),
    _Achievement(title: '1 Week', unlocked: false, iconPath: null),
    _Achievement(title: '2 Weeks', unlocked: false, iconPath: null),
    _Achievement(title: '1 Month', unlocked: false, iconPath: null),
    _Achievement(title: '2 Months', unlocked: false, iconPath: null),
    _Achievement(title: '3 Months', unlocked: false, iconPath: null),
    _Achievement(title: '6 Months', unlocked: false, iconPath: null),
    _Achievement(title: '1 Year', unlocked: false, iconPath: null),
  ];


  // Adjust this value to change the vertical position of the title label
  final double _titleBottomOffset = 4.0;
  // Adjust this value to change the size of the achievement icon
  final double _iconSize = 500.0;

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
      body: Stack(
        children: [
          // Background image or color if needed
          /*Positioned.fill(
            child: Image.asset(
              'assets/images/background/ground_vertical.png',
              fit: BoxFit.cover,
            ),
          ),*/
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 16, left: 16, right: 16),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achv = _achievements[index];
                return _buildAchievementTile(achv);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(_Achievement achievement) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Stats box background
        Image.asset(
          'assets/images/statistics/stats_box.png',
          fit: BoxFit.fill,
          width: double.infinity,
          height: double.infinity,
        ),
        if (achievement.unlocked && achievement.iconPath != null)
          Image.asset(
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
        // Title label positioned with adjustable bottom offset
        Positioned(
          bottom: _titleBottomOffset,
          child: Text(
            achievement.title,
            style: const TextStyle(
              fontFamily: 'RetroGaming',
              fontSize: 14,
              color: Color(0xFFE9E6A8),
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
