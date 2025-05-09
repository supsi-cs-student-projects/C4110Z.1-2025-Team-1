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
    final streak = await _streakService.loadStreak();
    final nowLocal = DateTime.now();
    final lastUpdatedLocal = streak.lastUpdated.toLocal();

    // Check if streak was already updated today
    if (_isSameDay(nowLocal, lastUpdatedLocal)) {
      print('Streak already incremented today.');
      //print time remaining until next day
      final timeRemaining = DateTime(
        lastUpdatedLocal.year,
        lastUpdatedLocal.month,
        lastUpdatedLocal.day + 1,
      ).difference(nowLocal);
      print('Time remaining until next increment: ${timeRemaining.inHours} hours, ${timeRemaining.inMinutes % 60} minutes');
      return;
    }

    // Check if a day was skipped → reset streak
    final daysBetween = nowLocal.difference(
      DateTime(lastUpdatedLocal.year, lastUpdatedLocal.month, lastUpdatedLocal.day),
    ).inDays;

    if (daysBetween > 1) {
      print('Missed a day — streak reset.');
      await _streakService.resetStreak();
      streakCount = 1;
      return;
    }

    // Otherwise, valid to increment
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
    milestoneManager.checkMilestones(xp);
    await _gameService.updateXP(xp);
  }

  /// Get current XP
  int getXP() {
    return xp;
  }
}
