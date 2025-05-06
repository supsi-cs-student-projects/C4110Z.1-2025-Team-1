import 'GameService.dart';

class MilestoneManager {
  final List<int> milestones = [50, 100, 200, 500, 1000];
  final Set<int> reachedMilestones = {};
  final GameService gameService;

  MilestoneManager({required this.gameService});

  void checkMilestones(int currentXP) async {
    for (int milestone in milestones) {
      if (currentXP >= milestone && !reachedMilestones.contains(milestone)) {
        reachedMilestones.add(milestone);
        await _onMilestoneReached(milestone);
      }
    }
  }

  Future<void> _onMilestoneReached(int milestone) async {
    print("You reached $milestone XP!");
    await gameService.updateMilestones(milestone);
  }

}
