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

  /// Increment the user's daily streak (only once per day)

  Future<void> incrementStreak() async {
    try {
      await _streakService.incrementStreak();
    } catch (e) {
      print('Failed to increment streak: $e');
    }
  }

  //REMOVE THIS AFTER DEBUGGING STREAK LOGIC
  Future<void> incrementStreakDebug() async {
    final updatedStreak = await _streakService.incrementStreak();
    streakCount = updatedStreak.streakCount;
    print('Streak incremented! New count: $streakCount');
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Increment XP by a given amount
  Future<void> addXP(int amount) async {
    xp += amount;
    milestoneManager.checkLevels(xp);
    await _gameService.updateXP(xp);
  }

  /// Get current XP
  int getXP() {
    return xp;
  }
}
