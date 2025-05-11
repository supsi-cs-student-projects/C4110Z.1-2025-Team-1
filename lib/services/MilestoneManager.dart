import 'GameService.dart';

class MilestoneManager {
  final List<int> levels = [50, 100, 250];
  final Set<int> reachedLevels = {};
  final List<int> medals = [1, 2, 3, 7, 14, 30, 60, 90, 180, 270, 365];
  final Set<int> reachedMedals = {};
  final GameService gameService;

  MilestoneManager({required this.gameService});

  void checkLevels(int currentXP) async {
    for (int level in levels) {
      if (currentXP >= level && !reachedLevels.contains(level)) {
        reachedLevels.add(level);
        await _onLevelReached(level);
      }
    }
  }

  Future<void> _onLevelReached(int level) async {
    print("You reached $level XP!");
    await gameService.updateMilestones(level);
  }

  void checkMedals(int currentStreak) async {
    for (int medal in medals) {
      if (currentStreak >= medal && !reachedMedals.contains(medal)) {
        reachedMedals.add(medal);
        await _onMedalReached(medal);
      }
    }
  }

  Future<void> _onMedalReached(int streak) async {
    print("You achieved $streak days medal!");
    //await gameService.updateMilestones(streak);
  }

}
