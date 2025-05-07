import '../services/GameService.dart';
import '../services/MilestoneManager.dart';
import '../services/Streak.dart';
import '../services/auth.dart';

class User {
  final String nickname;
  int higherLowerBestScore;
  int streakCount;
  int xp;

  final GameService _gameService = GameService();
  final StreakService _streakService = StreakService();
  final AuthService _authService = AuthService();
  final milestoneManager = MilestoneManager(gameService: GameService());

  User({
    required this.nickname,
    required this.higherLowerBestScore,
    required this.streakCount,
    required this.xp,
  });

  /// Fetch the user's stats from Appwrite
  static Future<User> fetchUser() async {
    try {
      final account = await AuthService().getAccount();
      final nickname = account.name;

      final gameService = GameService();
      final higherLowerBestScore = await gameService.getBestScore();
      final xp = await gameService.getXP();

      final streakCount = await StreakService().getStreakCount();

      return User(
        nickname: nickname,
        higherLowerBestScore: higherLowerBestScore,
        streakCount: streakCount,
        xp: xp,
      );
    } catch (e) {
      throw Exception('Failed to fetch user stats: $e');
    }
  }

  /// Update the user's higher-lower best score
  Future<void> updateHigherLowerBestScore(int newBestScore) async {
    if (newBestScore > higherLowerBestScore) {
      higherLowerBestScore = newBestScore;
      await _gameService.updateBestScore(newBestScore);
    }
  }

  /// Increment the user's streak count
  Future<void> incrementStreak() async {
    streakCount++;
    await _streakService.incrementStreak();
  }

  /// Increment XP by a given amount
  Future<void> addXP(int amount) async {
    xp += amount;
    milestoneManager.checkMilestones(xp);
    await _gameService.updateXP(xp);
  }

  /// Get current XP
  int getXP() {
    return xp;
  }
}
